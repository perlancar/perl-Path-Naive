package Path::Naive;

use 5.010001;
use strict;
use warnings;

# VERSION

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
                       split_path
                       normalize_path
                       is_abs_path
                       is_rel_path
                       concat_path
                       concat_path_n
                       abs_path
               );

sub split_path {
}

sub normalize_path {
}

sub is_abs_path {
}

sub is_rel_path {
}

sub concat_path {
}

sub concat_path_n {
}

sub abs_path {
}

1;
# ABSTRACT: Yet another abstract, Unix-like path manipulation routines

=head1 SYNOPSIS

 use Path::Naive qw(
     split_path concat_path normalize_path abs_path
     is_abs_path is_rel_path);

 # split path to directories
 $dirs = split_path("");              # dies, empty path
 $dirs = split_path("/");             # -> []
 $dirs = split_path("a");             # -> ["a"]
 $dirs = split_path("/a");            # -> ["a"]
 $dirs = split_path("/a/");           # -> ["a"]
 $dirs = split_path("../a");          # -> ["..", "a"]
 $dirs = split_path("./a");           # -> [".", "a"]
 $dirs = split_path("../../a");       # -> ["..", "..", "a"]
 $dirs = split_path(".././../a");     # -> ["..", ".", "..", "a"]
 $dirs = split_path("a/b/c..");       # -> ["a", "b", "c", ".."]

 # normalize path (collapse . & .., remove double & trailing / except on "/")
 say normalize_path("");              # dies, empty path
 say normalize_path("/");             # -> "/"
 say normalize_path("..");            # -> ".."
 say normalize_path("./");            # -> "."
 say normalize_path("//");            # -> "/"
 say normalize_path("a/b/.");         # -> "a/b"
 say normalize_path("a/b/./");        # -> "a/b"
 say normalize_path("a/b/..");        # -> "a"
 say normalize_path("a/b/../");       # -> "a"
 say normalize_path("/a/./../b");     # -> "b"
 say normalize_path("/a/../../b");    # -> "b" (.. after hitting root is ok)

 # check whether path is absolute (starts from root)
 say is_abs_path("/");                # -> 1
 say is_abs_path("/a");               # -> 1
 say is_abs_path("/..");              # -> 1
 say is_abs_path(".");                # -> 0
 say is_abs_path("./b");              # -> 0
 say is_abs_path("b/c/");             # -> 0

 # this is basically just !is_abs_path($path)
 say is_rel_path("/");                # -> 0
 say is_rel_path("a/b");              # -> 1

 # concatenate two paths
 say concat_path("a", "b");           # -> "a/b"
 say concat_path("a/", "b");          # -> "a/b"
 say concat_path("a", "b/");          # -> "a/b/"
 say concat_path("a", "../b/");       # -> "/b/"
 say concat_path("a/b", ".././c");    # -> "a/./c"
 say concat_path("../", ".././c/");   # -> "../../c/"

 # this is just concat_path + normalize_path the result
 say concat_path_n("a", "b");         # -> "a/b"
 say concat_path_n("a/", "b");        # -> "a/b"
 say concat_path_n("a", "b/");        # -> "a/b"
 say concat_path_n("a", "../b/");     # -> "/b"
 say concat_path_n("a/b", ".././c");  # -> "a/c"
 say concat_path_n("../", ".././c/"); # -> "../../c"

 # abs_path($path, $base) is equal to concat_path($base, $path). $base must be
 # absolute.
 say abs_path("a", "b");              # dies, $base is not absolute
 say abs_path("a", "/b");             # -> "/b/a"
 say abs_path(".", "/b");             # -> "/b"
 say abs_path("a/c/..", "/b/");       # -> "/b/a"
 say abs_path("/a", "/b/c");          # -> "/a"


=head1 DESCRIPTION

This is yet another set of routines to manipulate abstract Unix-like paths.
C<Abstract> means not tied to actual filesystem. B<Unix-like> means single-root
tree, with forward slash C</> as separator, and C<.> and C<..> to mean current-
and parent directory. C<Naive> means not having the concept of symlinks, so
paths need not be traversed on a per-directory basis (see L<File::Spec::Unix>
where it mentions the word "naive").

These routines can be useful if you have a tree data and want to let users walk
around it using filesystem-like semantics. Some examples of where these routines
are used: Config::Tree, L<Riap> (L<App::riap>).


=head1 FUNCTIONS

=head2 split_path($path) => ARRAY OF STR

=head2 normalize_path($path) => STR

=head2 is_abs_path($path) => BOOL

=head2 is_rel_path($path) => BOOL

=head2 concat_path($path1, $path2) => STR

=head2 concat_path_n($path1, $path2) => STR

=head2 abs_path($path) => STR


=head1 SEE ALSO

L<Path::Abstract> a similar module. The difference is, it does not interpret
C<.> and C<..>.

L<File::Spec::Unix> a similar module, with some differences in parsing behavior.

=cut
