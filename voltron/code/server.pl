use 5.010;
use POE;
use Voltron::Server;

Voltron::Server->new
(
    listen_ip   => 127.0.0.1,
    listen_port => 12345,
    alias       => 'master',
    options     => { trace => 0, debug => 1 },
);

POE::Kernel->run();

