package XMLRPC::Server::Types;
use warnings;
use strict;
use 5.010;

use MooseX::Types -declare => 
[ 
    qw/ 
        HttpMessage 
        XmlMessage 
        XMLRPCResponse 
        XMLRPCRequest 
        PFX
        PFSH
        FMAP
        PFXRPC
        STACKABLE
    / 
];

use MooseX::Types::Moose('Object');

subtype HttpMessage, as Object, where { $_->isa('HTTP::Message') };
subtype XmlMessage, as Object, where { $_->isa('POE::Filter::XML::Node') };
subtype XMLRPCRequest, as Object, where { $_->isa('POE::Filter::XML::RPC::Request') };
subtype XMLRPCResponse, as Object, where { $_->isa('POE::Filter::XML::RPC::Response') };

subtype PFX, as class_type('POE::Filter::XML');
subtype PFSH, as class_type('POE::Filter::SimpleHTTP');
subtype FMAP, as class_type('POE::Filter::Map');
subtype PFXRPC, as class_type('POE::Filter::XML::RPC');
subtype STACKABLE, as class_type('POE::Filter::Stackable');
1;
__END__
