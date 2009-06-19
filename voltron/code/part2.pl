use 5.010;
use POE;
use MooseX::Declare;

class MyParticipant with Voltron::Participant
{
    use POEx::Types(':all');
    use Voltron::Types(':all');
    use MooseX::Types::Moose(':all');

    use aliased 'POEx::Role::Event';
    use aliased 'Voltron::Role::VoltronEvent';

    method participant_check(Bool :$success, ServerConnectionInfo :$serverinfo, Ref :$payload?) is Event
    {
        if($success)
        {
            say 'Participant registered successfully';
            $self->yield('fire_ping');
        }
        else
        {
            die "Participant failed to register: $$payload";
        }
    }

    method application_added(Application :$application) is Event
    {
        say 'Application added';
    }

    method application_removed(Application :$application) is Event
    {
        say 'Application removed';
    }

    method fire_ping is Event
    {
        $self->post('MyApplication', 'ping', $self->name);
        $self->poe->kernel->delay_add('fire_ping', 1.0);
    }

    method pong(Str $application_name) is VoltronEvent
    {
        say "Received pong from $application_name";
    }
}

my $par = MyParticipant->new
(
    alias                   => 'MyParticipant2',
    name                    => 'MyParticipant2',
    application_name        => 'MyApplication',
    version                 => 1.00,
    requires                => { ping => '(Str $participant_name)' },
    options                 => { debug => 1, trace => 0 },
    server_configs =>
    [
        {
            remote_address  => '127.0.0.1',
            remote_port     => 12345,
            return_session  => 'MyParticipant2',
            return_event    => 'participant_check',
            server_alias    => 'test_server',
        }
    ]
);


POE::Kernel->run();
