package WebGUI::Install::Manual;

# ABSTRACT: What is this and how do I use it?

1;

=head1 WHAT IS THIS?

WebGUI::Install is a way to manage extensions for WebGUI
(L<http://webgui.org/>), an open source Perl CMS. It aims to make versioned
installation of WebGUI extensions from the CPAN practical and attractive. 

This document describes how to use WebGUI::Install and offers some suggested
practices for common tasks that this module doesn't directly address.

=head1 DEFINITIONS

The core functionality of WebGUI::Install is version management. You, as the
author of a WebGUI extension, provide a Definition module, and WebGUI::Install
executes whatever pieces of it are necessary to bring your WebGUI environment
to the desired version of your extension.

A definition module is required to provide a C<$VERSION> package variable and
implement one subroutine named C<version_info> which returns a hash reference.
The keys are version numbers, and the values are hash references containing
(optionally):

    upgrade => sub { ... }
    downgrade => sub { ... }

When a user tries to upgrade to your version, all upgrade subs from his 
current version (potentially 0, not installed) up to and including the
upgrade sub for the vesion he requested are run in order. Similarly, when he
tries to downgrade to a particular version, all downgrade subs starting with
the current version, down to (but not including) the downgrade sub for the
version he requested are run in order.

L<WebGUI::Install::Definition> provides a small DSL for authoring these
definition modules. See its synopsis for an example.

=head1 INSTALLATION

When you want to install the latest version of an extension, simply issue
C<wgi My::Definition::Module>. It will be fetched using L<CPANPLUS> and your
L</"WEBGUI ENVIRONMENT"> will be modified accordingly (config file updated,
database tables created, etc).

If you want something other than the latest version, you can specify a version
and a distribution name or archive file. See the command's
L<documentation|WebGUI::Install::Command::install> for the exact syntax.

=head1 WHAT IF MY EXTENSION ISN'T ON CPAN?

You still need to package your extension according to CPAN conventions. You
can then either install from a tarball or use L<CPAN::Mini::Inject> with a
local CPAN mirror (recommended).

=head1 WHAT ABOUT PACKAGES AND OTHER COLLATERAL?

One of the less well-known features of Perl's module system is the ability for
each module to keep static files in a special "share" directory. This is
detailed further in L<File::ShareDir>. L<WebGUI::Install::Collateral>
provides utility functions for managing packages and extras placed inside
these share directories. L<Dist::Zilla> (recommended) has a
L<plugin|Dist::Zilla::Plugin::ModuleShareDirs> for installing these, though it
is also possible with other build systems.

=head1 WEBGUI ENVIRONMENT

To do anything interesting with WebGUI, you need a WebGUI::Session.  To that
end, all WebGUI::Install commands require an extra argument for the config
file (see the L<documentation|WebGUI::Install::Command> for details).
Optionally, you can specify the WebGUI root directory (this defaults to
/data/WebGUI, since that is where most people keep it).

The excellent WGDev (L<http://github.org/haarg/WGDev>) tool already has a system
for managing this, and using the L<WGDev::Command::Wgi> plugin provided with
this distribution allows you to take advantage of it.

=head1 WHAT IF MY TESTS NEED A WEBGUI SESSION?

Some of them, at least, probably do. If you C<use> L<WebGUI::Test::Skip>
(included with this distrubtion) at the top of a test file, all its tests will
be skipped unless WebGUI::Test loads properly. This way you can still test
your extensions thoroughly without having to worry about causing install
problems for CPAN users. If they install your extension with WebGUI::Install,
they'll have a useful WebGUI environment set up and the tests will still get
run.

=head1 WHAT ABOUT SUPPORTING DIFFERENT WEBGUI VERSIONS?

If your extension is popular enough to need to be supported across various
WebGUI versions, you may need to do conditional checks in your code to make
different api calls or alter the install process. L<WebGUI::Install::WGVersion>
has some utilities to make the check itself painless, but there is some
inherent complexity to handling different versions well. Sorry.

=head1 WHAT IF SOMETHING GOES WRONG?

The install command does everything inside of a database transaction and makes
use of L<Config::JSON>'s transactional capabilities, but you should still
backup production sites before using this tool on them.
