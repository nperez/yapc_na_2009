use 5.010;
use POE;
use MooseX::Declare;

class MyApplication with Voltron::Application
{
    use POEx::Types(':all');
    use Voltron::Types(':all');
    use MooseX::Types::Moose(':all');

    use aliased 'POEx::Role::Event';
    use aliased 'Voltron::Role::VoltronEvent';

    method application_check(Bool :$success, ServerConnectionInfo :$serverinfo, Ref :$payload?) is Event
    {
        if($success)
        {
            say 'Application registered successfully';
        }
        else
        {
            die "Application failed to register: $$payload";
        }
    }

    method participant_added(Participant :$participant) is Event
    {
        say 'Participant ('.$participant->{participant_name}.') added';
    }

    method participant_removed(Participant :$participant) is Event
    {
        say 'Participant ('.$participant->{participant_name}.') removed';
    }

    method ping(Str $participant_name) is VoltronEvent
    {
        say "Received ping from particpant $participant_name";
        $self->post($participant_name, 'pong', $self->name);
    }
}

my $app = MyApplication->new
(
    alias                   => 'MyApplication',
    name                    => 'MyApplication',
    version                 => 1.00,
    min_participant_version => 1.00,
    requires                => { pong => '(Str $application_name)' },
    options                 => { trace => 0, debug => 1 },
    server_configs =>
    [
        {
            remote_address  => '127.0.0.1',
            remote_port     => 12345,
            return_session  => 'MyApplication',
            return_event    => 'application_check',
            server_alias    => 'test_server',
        }
    ]

);

POE::Kernel->run();
