#!perl

use 5.010;
use strict;
use warnings;

use Path::Naive qw(
                       split_path
                       normalize_path
                       is_abs_path
                       is_rel_path
                       concat_path
                       concat_path_n
                       abs_path
              );
use Test::Exception;
use Test::More 0.98;

dies_ok { split_path() };
dies_ok { split_path(undef) };
dies_ok { split_path("") };
is_deeply(split_path("/")          , []);
is_deeply(split_path("a")          , ["a"]);
is_deeply(split_path("/a")         , ["a"]);
is_deeply(split_path("/a/")        , ["a"]);
is_deeply(split_path("../a")       , ["..", "a"]);
is_deeply(split_path("./a")        , [".", "a"]);
is_deeply(split_path("../../a")    , ["..", "..", "a"]);
is_deeply(split_path(".././../a")  , ["..", ".", "..", "a"]);
is_deeply(split_path("a/b/c..")    , ["a", "b", "c", ".."]);

dies_ok { normalize_path() };
dies_ok { normalize_path(undef) };
dies_ok { normalize_path("") };
is(normalize_path("/")             , "/");
is(normalize_path("..")            , "..");
is(normalize_path("./")            , ".");
is(normalize_path("//")            , "/");
is(normalize_path("a/b/.")         , "a/b");
is(normalize_path("a/b/./")        , "a/b");
is(normalize_path("a/b/..")        , "a");
is(normalize_path("a/b/../")       , "a");
is(normalize_path("/a/./../b")     , "b");
is(normalize_path("/a/../../b")    , "b");

dies_ok { is_abs_path() };
dies_ok { is_abs_path(undef) };
dies_ok { is_abs_path("") };
is(is_abs_path("/")                , 1);
is(is_abs_path("/a")               , 1);
is(is_abs_path("/..")              , 1);
is(is_abs_path(".")                , 0);
is(is_abs_path("./b")              , 0);
is(is_abs_path("b/c/")             , 0);

dies_ok { is_rel_path() };
dies_ok { is_rel_path(undef) };
dies_ok { is_rel_path("") };
is(is_rel_path("/")                , 0);
is(is_rel_path("a/b")              , 1);

dies_ok { concat_path() };
dies_ok { concat_path(undef) };
dies_ok { concat_path("") };
is(concat_path("a", "b")            , "a/b");
is(concat_path("a/", "b")           , "a/b");
is(concat_path("a", "b/")           , "a/b/");
is(concat_path("a", "../b/")        , "/b/");
is(concat_path("a/b", ".././c")     , "a/./c");
is(concat_path("../", ".././c/")    , "../../c/");

dies_ok { concat_path_n() };
dies_ok { concat_path_n(undef) };
dies_ok { concat_path_n("") };
is(concat_path_n("a", "b")          , "a/b");
is(concat_path_n("a/", "b")         , "a/b");
is(concat_path_n("a", "b/")         , "a/b");
is(concat_path_n("a", "../b/")      , "/b");
is(concat_path_n("a/b", ".././c")   , "a/c");
is(concat_path_n("../", ".././c/")  , "../../c");

dies_ok { abs_path() };
dies_ok { abs_path(undef) };
dies_ok { abs_path("") };
dies_ok { abs_path("a", "b") } "base not absolute";
is(abs_path("a", "/b")              , "/b/a");
is(abs_path(".", "/b")              , "/b");
is(abs_path("a/c/..", "/b/")        , "/b/a");
is(abs_path("/a", "/b/c")           , "/a");

DONE_TESTING:
done_testing();
