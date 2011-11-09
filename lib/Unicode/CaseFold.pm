package Unicode::CaseFold;

# ABSTRACT: Unicode case-folding made easy
# VERSION
# AUTHORITY

use strict;
use warnings;

use Unicode::UCD ();

my $WHICH_MAPPING = ($] >= 5.011 ? "full" : "mapping");

sub case_fold {
  my ($string) = @_;

  my $out = "";

  for my $codepoint (unpack "U*", $string) {
    my $mapping = Unicode::UCD::casefold($codepoint);
    my @cp;
    if (!defined $mapping) {
      @cp = ($codepoint);
    } else {
      @cp = map hex, split / /, $mapping->{$WHICH_MAPPING};
    }
    $out .= pack "U*", @cp;
  }

  return $out;
}

require XSLoader;
XSLoader::load(__PACKAGE__, $VERSION);

1;
