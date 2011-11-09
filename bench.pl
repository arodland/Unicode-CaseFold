use Unicode::CaseFold;
use charnames ':full';
use Benchmark 'cmpthese';

my $str = "Wei\N{LATIN SMALL LETTER SHARP S}" x 1000;

cmpthese(-10,
  {
    pp    => sub { my $throwaway = Unicode::CaseFold::case_fold($str) },
    xs    => sub { my $throwaway = Unicode::CaseFold::case_fold_xs($str) },
    lc    => sub { my $throwaway = lc $str },
  }
);
