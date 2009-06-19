package XMLRPC::Server;
use 5.010;

use MooseX::Declare;

role XMLRPC::Server with POEx::Role::TCPServer
{
    use XMLRPC::Server::Types(':all');
    use POEx::Types(':all');
    use MooseX::Types::Moose(':all');

    use POE::Filter::XML;
    use POE::Filter::XML::Node;
    
    use POE::Filter::XML::RPC;
    use POE::Filter::XML::RPC::Response;
    use POE::Filter::XML::RPC::Request;
    use POE::Filter::XML::RPC::Fault;
    use POE::Filter::XML::RPC::Value;

    use POE::Filter::SimpleHTTP;
    use POE::Filter::Map;
    use POE::Filter::Stackable;
    
    use HTTP::Request;
    use HTTP::Response;

    use aliased 'POEx::Role::Event', 'Event';

    has pfx => 
    (
        is      => 'ro', 
        isa     => PFX, 
        default => sub { POE::Filter::XML->new(NOTSTREAMING => 1) }
    );

    has pfxrpc =>
    (
        is      => 'ro',
        isa     => PFXRPC,
        default => sub { POE::Filter::XML::RPC->new() }
    );

    has pfsh =>
    (
        is      => 'ro',
        isa     => PFSH,
        default => sub { POE::Filter::SimpleHTTP->new(mode => +PFSH_SERVER) }
    );

    has fmap1 =>
    (
        is      => 'ro',
        isa     => FMAP,
        default => sub
        {

            POE::Filter::Map->new
            (
                Get => sub
                {
                    return shift;
                },

                Put => sub
                {
                    return shift->as_string;
                }
            );
        }
        
    );
    
    has fmap2 =>
    (
        is      => 'ro',
        isa     => FMAP,
        default => sub
        {

            POE::Filter::Map->new
            (
                Get => sub
                {
                    return shift()->content();
                },

                Put => sub
                {
                    return shift;
                }
            );
        }
    );

    has stack =>
    (
        is          => 'rw',
        isa         => STACKABLE,
        lazy_build  => 1,
    );

    method _build_stack
    {
        my $stack = POE::Filter::Stackable->new();
        $stack->push($self->fmap1, $self->pfsh, $self->fmap2, $self->pfx, $self->pfxrpc);
        return $stack;
    }

    after _start is Event
    {
        $self->filter($self->stack);
    }

    method handle_inbound_data(XMLRPCRequest|XMLRPCResponse $request, WheelID $id) is Event
    {
        my $response;

        if(is_XMLRPCResponse($request))
        {
            $response = $request;
        }
        else
        {
            my $meta = $self->meta;
            my $method = $meta->get_method($request->method_name);
            
            if(!$method)
            {
                $response = POE::Filter::XML::RPC::Response->new
                (
                    POE::Filter::XML::RPC::Fault->new('404', 'Method not found!')
                );
            }
            else
            {
                my $return;
                eval
                {
                    $return = $method->execute($self, map { $_->value } @{$request->parameters});
                };
                
                if($@)
                {
                    $response = POE::Filter::XML::RPC::Response->new
                    (
                        POE::Filter::XML::RPC::Fault->new('409', $@)
                    );
                }
                else
                {
                    $response = POE::Filter::XML::RPC::Response->new
                    (
                        POE::Filter::XML::RPC::Value->new($return)
                    );
                }
            }
        }
        
        $self->get_wheel($id)->put($response);
    }

    around handle_on_flushed(WheelID $id) is Event
    {
        $self->delete_wheel($id);
    }
}
1;
__END__
