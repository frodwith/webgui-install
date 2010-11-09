package WebGUI::Install::Command;

use Moose;
use File::Spec;
use File::Copy;
use Try::Tiny;
extends 'MooseX::App::Cmd::Command';

has _inked => (
    accessor => 'inked',
    isa      => 'Bool',
    default  => 0,
);

has _session => (
    reader   => 'session',
    isa      => 'WebGUI::Session',
    lazy     => 1,
    required => 1,
    default  => sub {
        my $self = shift;
        $self->ink();
        require WebGUI;
        require WebGUI::Session;
        my $cfg = $self->config_filename;
        if ($WebGUI::VERSION =~ /^8/) {
            return WebGUI::Session->open($cfg);
        }
        return WebGUI::Session->open($self->webgui_root, $cfg);
    },
);

has config_filename => (
    is          => 'ro',
    isa         => 'Str',
    metaclass   => 'MooseX::Getopt::Meta::Attribute',
    required    => 1,
    cmd_aliases => [qw(configFile config)],
);

has webgui_root => (
    is          => 'ro',
    isa         => 'Str',
    metaclass   => 'MooseX::Getopt::Meta::Attribute',
    required    => 1,
    default     => '/data/WebGUI',
    cmd_aliases => [qw(root wgRoot)],
);

augment execute => sub {
    my $self = shift;
    $self->ink();
    $self->txn_do(sub { inner() });
};

sub ink {
    my $self = shift;
    return if $self->inked;
    my $root = $self->webgui_root;
    my $lib = File::Spec->catfile($self->webgui_root, 'lib');
    unshift @INC, File::Spec->rel2abs($lib);
    $self->inked(1);
}

sub txn_do {
    my ($self, $block) = @_;
    my $session = $self->session;
    my $db      = $session->db;
    my $path    = $session->config->pathToFile;
    my $config = do { 
        open my $fh, '<', $path;
        local $/; 
        <fh>;
    };

    $db->beginTransaction();
    
    try {
        &$block;
        $db->commit();
    }
    catch {
        print STDERR "$_\nError: cleaning up.\n";
        $db->rollback();
        open my $fh, '>', $path;
        print {$fh} $config;
    };
}

1;
