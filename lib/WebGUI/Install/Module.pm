package WebGUI::Install::Module;

use Moose;
use version;

has session => (
    is       => 'ro',
    isa      => 'WebGUI::Session',
    required => 1,
);

has package => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has _version_info => (
    is       => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub { $_[0]->package->version_info }
);

has _versions => (
    traits  => ['Array'],
    isa     => 'ArrayRef',
    lazy    => 1,
    builder => '_build_ordered_versions',
    handles => {
        ordered_versions => 'elements',
    },
);

sub _build_ordered_versions {
    my $self = shift;
    my $info = $self->_version_info;
    [ sort { $a <=> $b } map { version->parse($_) } keys (%$info) ];
}

around BUILDARGS => sub {
    my ($super, $class, $session, $pkg) = @_;
    return $class->$super(
        session => $session, 
        package => $class->extension_name($pkg),
    );
};

sub BUILD {
    my $self  = shift;
    my $class = ref $self;
    my $pkg   = $self->package;
    $class->load_package($pkg);
    die "$pkg has no version_info method" unless $pkg->can('version_info');
};

has current_version => (
    is      => 'rw',
    lazy    => 1,
    builder => 'read_current_version',
    trigger => sub { my $self = shift; $self->write_current_version(@_) },
);

sub write_current_version {
    my ($self, $val) = @_;
    my $sql = 'UPDATE WGI_Versions SET version = ? WHERE extension = ?';
    $self->session->db->write($sql, [ $val, $self->package ]);
}

sub read_current_version {
    my $self = shift;
    my $sql  = 'SELECT version FROM WGI_Versions WHERE extension = ?';
    version->parse($self->session->db->quickScalar($sql, [ $self->package ]));
}

sub load_package {
    my ($class, $pkg) = @_;
    no strict 'refs';
    return if scalar %{$pkg . '::'};
    eval "require $pkg" or die $@;
}

sub extension_name {
    my ($class, $name) = @_;
    return $name =~ /^\+/ 
        ? substr($name, 1)
        : "WebGUI::Install::Extension::$name";
}

sub upgrade {
    my ($self, $from, $to) = @_;
    my $session = $self->session;
    my @versions = $self->ordered_versions;
    shift(@versions) while ($versions[0] <= $from);
    pop(@versions)   while ($versions[-1] > $to);
    my $info = $self->_version_info;

    for my $v (@versions) {
        my $i = $info->{$v} or next;
        my $u = $i->{upgrade} or next;
        $u->($session);
    }
    $self->current_version($to);
}

sub downgrade {
    my ($self, $from, $to) = @_;
    my $session = $self->session;
    my @versions = $self->ordered_versions;
    pop(@versions)   while ($versions[-1] > $from);
    shift(@versions) while ($versions[0] <= $to);
    my $info = $self->_version_info;
    for my $v (reverse @versions) {
        my $i = $info->{$v} or next;
        my $d = $i->{downgrade} or next;
        $d->($session);
    }
    $self->current_version($to);
}

sub target_version {
    my ($self, $str) = @_;
    return ($self->ordered_versions)[-1] unless defined $str;
    return version->parse($str);
}

sub up_or_downgrade {
    my ($self, $target) = @_;

    my $current = $self->current_version || 0;
    $target = $self->target_version($target);

    if ($current < $target) {
        $self->upgrade($current, $target);
    }
    elsif ($current > $target) {
        $self->downgrade($current, $target);
    }
}

1;
