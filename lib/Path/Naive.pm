package Path::Naive;

# AUTHORITY
# DATE
# DIST
# VERSION

use strict;
use warnings;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
    abs_path
    concat_path
    concat_and_normalize_path
    normalize_path
    is_abs_path
    is_rel_path
    split_path
);

sub abs_path {
    my ($path, $base) = @_;

    die "Please specify path (first arg)" unless defined $path && length $path;
    die "Please specify base (second arg)" unless defined $base && length $base;
    die "base must be absolute" unless is_abs_path($base);
    concat_and_normalize_path($base, $path);
}

sub is_abs_path {
    my $path = shift;
    die "Please specify path" unless defined $path && length $path;
    $path =~ m!\A/! ? 1:0;
}

sub is_rel_path {
    my $path = shift;
    die "Please specify path" unless defined $path && length $path;
    $path =~ m!\A/! ? 0:1;
}

sub normalize_path {
    my $path = shift;
    my @elems0 = split_path($path);
    my $is_abs = $path =~ m!\A/!;
    my @elems;
    while (@elems0) {
        my $elem = shift @elems0;
        next if $elem eq '.' && (@elems || @elems0 || $is_abs);
        do { pop @elems; next } if $elem eq '..' &&
            (@elems>1 && $elems[-1] ne '..' ||
                 @elems==1 && $elems[-1] ne '..' && $elems[-1] ne '.' && @elems0 ||
                     $is_abs);
        push @elems, $elem;
    }
    ($is_abs ? "/" : "") . join("/", @elems);
}

sub split_path {
    my $path = shift;
    die "Please specify path" unless defined $path && length $path;
    grep {length} split qr!/+!, $path;
}

sub concat_path {
    die "Please specify at least two paths" unless @_ > 1;
    my $i = 0;
    my $res = $_[0];
    for (@_) {
        die "Please specify path (#$i)" unless defined && length;
        next unless $i++;
        if (m!\A/!) {
            $res = $_;
        } else {
            $res .= ($res =~ m!/\z! ? "" : "/") . $_;
        }
    }
    $res;
}

sub concat_and_normalize_path {
    normalize_path(concat_path(@_));
}

1;
# ABSTRACT: Yet another abstract, Unix-like path manipulation routines

=for Pod::Coverage ^(split_path concat_path_n)$

=head1 SYNOPSIS

 use Path::Naive qw(
     abs_path
     concat_path
     concat_and_normalize_path
     normalize_path
     is_abs_path
     is_rel_path
     split_path
);

 # split path to its elements.
 @dirs = split_path("");              # dies, empty path
 @dirs = split_path("/");             # -> ()
 @dirs = split_path("a");             # -> ("a")
 @dirs = split_path("/a");            # -> ("a")
 @dirs = split_path("/a/");           # -> ("a")
 @dirs = split_path("../a");          # -> ("..", "a")
 @dirs = split_path("./a");           # -> (".", "a")
 @dirs = split_path("../../a");       # -> ("..", "..", "a")
 @dirs = split_path(".././../a");     # -> ("..", ".", "..", "a")
 @dirs = split_path("a/b/c/..");      # -> ("a", "b", "c", "..")

 # normalize path (collapse . & .., remove double & trailing / except on "/").
 $p = normalize_path("");              # dies, empty path
 $p = normalize_path("/");             # -> "/"
 $p = normalize_path("..");            # -> ".."
 $p = normalize_path("./");            # -> "."
 $p = normalize_path("//");            # -> "/"
 $p = normalize_path("a/b/.");         # -> "a/b"
 $p = normalize_path("a/b/./");        # -> "a/b"
 $p = normalize_path("a/b/..");        # -> "a"
 $p = normalize_path("a/b/../");       # -> "a"
 $p = normalize_path("/a/./../b");     # -> "/b"
 $p = normalize_path("/a/../../b");    # -> "/b" (.. after hitting root is ok)

 # check whether path is absolute (starts from root).
 say is_abs_path("/");                # -> 1
 say is_abs_path("/a");               # -> 1
 say is_abs_path("/..");              # -> 1
 say is_abs_path(".");                # -> 0
 say is_abs_path("./b");              # -> 0
 say is_abs_path("b/c/");             # -> 0

 # this is basically just !is_abs_path($path).
 say is_rel_path("/");                # -> 0
 say is_rel_path("a/b");              # -> 1

 # concatenate two paths.
 say concat_path("a", "b");           # -> "a/b"
 say concat_path("a/", "b");          # -> "a/b"
 say concat_path("a", "b/");          # -> "a/b/"
 say concat_path("a", "../b/");       # -> "a/../b/"
 say concat_path("a/b", ".././c");    # -> "a/b/.././c"
 say concat_path("../", ".././c/");   # -> "../.././c/"
 say concat_path("a/b/c", "/d/e");    # -> "/d/e" (path2 is absolute)

 # this is just concat_path + normalize_path the result. note that it can return
 # path string (in scalar context) or path elements (in list context).
 $p = concat_and_normalize_path("a", "b");         # -> "a/b"
 $p = concat_and_normalize_path("a/", "b");        # -> "a/b"
 $p = concat_and_normalize_path("a", "b/");        # -> "a/b"
 $p = concat_and_normalize_path("a", "../b/");     # -> "b"
 $p = concat_and_normalize_path("a/b", ".././c");  # -> "a/c"
 $p = concat_and_normalize_path("../", ".././c/"); # -> "../../c"

 # abs_path($path, $base) is equal to concat_path_n($base, $path). $base must be
 # absolute.
 $p = abs_path("a", "b");              # dies, $base is not absolute
 $p = abs_path("a", "/b");             # -> "/b/a"
 $p = abs_path(".", "/b");             # -> "/b"
 $p = abs_path("a/c/..", "/b/");       # -> "/b/a"
 $p = abs_path("/a", "/b/c");          # -> "/a"


=head1 DESCRIPTION

This is yet another set of routines to manipulate abstract Unix-like paths.
B<Abstract> means not tied to actual filesystem. B<Unix-like> means single-root
tree, with forward slash C</> as separator, and C<.> and C<..> to mean current-
and parent directory. B<Naive> means not having the concept of symlinks, so
paths need not be traversed on a per-directory basis (see L<File::Spec::Unix>
where it mentions the word "naive").

These routines can be useful if you have a tree data and want to let users walk
around it using filesystem-like semantics. Some examples of where these routines
are used: Config::Tree, L<Riap> (L<App::riap>).


=head1 FUNCTIONS

=head2 abs_path($path) => str

=head2 concat_path_n($path1, $path2, ...) => str

=head2 concat_path($path1, $path2, ...) => str

=head2 is_rel_path($path) => bool

=head2 is_abs_path($path) => bool

=head2 normalize_path($path) => str

=head2 split_path($path) => list


=head1 SEE ALSO

L<Path::Abstract> a similar module. The difference is, it does not interpret
C<.> and C<..>.

L<File::Spec::Unix> a similar module, with some differences in parsing behavior.

=cut
