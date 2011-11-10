package Unicode::CaseFold;

# ABSTRACT: Unicode case-folding made easy
BEGIN {
  # VERSION
}
# AUTHORITY

use strict;
use warnings;

use 5.008001;

use Unicode::UCD ();

use Exporter 'import';
our @EXPORT_OK = qw(case_fold);
our @EXPORT = qw(fc);

our $LEGACY_MAPPING = $^V lt v5.10.0;
our $XS = 0;

sub case_fold {
  my ($string) = @_;

  my $WHICH_MAPPING = $LEGACY_MAPPING ? 'mapping' : 'full';

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

sub fc(;$) {
  @_ = ($_) unless @_;
  goto \&case_fold;
}

BEGIN {
  unless ($ENV{PERL_UNICODE_CASEFOLD_PP}) {
    eval {
      our $VERSION;
      require XSLoader;
      XSLoader::load(__PACKAGE__, $VERSION);
      $XS = 1;
      $LEGACY_MAPPING = 0;
    };
  }
}

1;
