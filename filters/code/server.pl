use 5.010;

use lib './lib';
use POE;
use MooseX::Declare;

class MyServer with XMLRPC::Server 
{
    use MooseX::Types::Moose(':all');
    use aliased 'POEx::Role::Event';
    use aliased 'XMLRPC::Server::Method', 'XmlRpcMethod';

    method add (Int $int1, Int $int2) is XmlRpcMethod returns (Int)
    {
        say "add method called ($int1 + $int2)";
        return $int1 + $int2;
    }

    method subtract (Int $int1, Int $int2) is XmlRpcMethod returns (Int)
    {
        say "subtract method called ($int1 - $int2)";
        return $int1 - $int2;
    }

    method multiply (Int $int1, Int $int2) is XmlRpcMethod returns (Int)
    {
        say "multiply method called ($int1 * $int2)";
        return $int1 * $int2;
    }

    method divide (Int $int1, Int $int2) is XmlRpcMethod returns (Int)
    {
        say "divide method called ($int1 / $int2)";
        return int($int1 / $int2);
    }
}

MyServer->new
(
    listen_ip => '127.0.0.1',
    listen_port => 54321,
    alias => 'MyServer',
    options => { trace => 1, debug => 1 }
);

POE::Kernel->run();
