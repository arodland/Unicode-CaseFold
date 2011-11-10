package Unicode::CaseFold;

# ABSTRACT: Unicode case-folding for case-insensitive lookups.

BEGIN {
  # VERSION
}
# AUTHORITY

use strict;
use warnings;

use 5.008001;

use Unicode::UCD ();
use Scalar::Util 1.11 ();

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

sub fc {
  @_ = ($_) unless @_;
  goto \&case_fold;
}

BEGIN {

  # Perl 5.10+ supports the (_) prototype which does the $_-defaulting for us,
  # and handles "lexical $_". Older perl doesn't, but we can fake it fairly
  # closely with a (;$) prototype. Older perl didn't have lexical $_ anyway.

  if ($^V ge v5.10.0) {
    Scalar::Util::set_prototype(\&fc, '_');
  } else {
    Scalar::Util::set_prototype(\&fc, ';$');
  }

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

__END__

=head1 DESCRIPTION

This module provides Unicode case-folding for Perl. Case-folding is a tool
that allows a program to make case-insensitive comparisons or do
case-insensitive lookups.

=head1 SYNOPSIS

XXX TODO

=head2 What is Case-Folding?

In non-Unicode contexts, a common idiom to compare two strings
case-insensitively is C<lc($this) eq lc($that)>. Before comparing two strings
we I<normalize> them to an all-lowercase version. C<"Hello">, C<"HELLO">, and
C<"HeLlO"> all have the same lowercase form (C<"hello">), so it doesn't matter
which one we start with; they are all equal to one another after C<lc>.

In Unicode, things aren't so simple. A Unicode character might have mappings
for I<uppercase>, I<lowercase>, and I<titlecase>, and the lowercase mapping of
the uppercase mapping of a given character might not be the character that you
started with! For example C<< lc(uc("\N{LATIN SMALL LETTER SHARP S")) >> is
C<"ss">, not the eszett we started off with! Case-folding is a part of the
Unicode standard that allows any two strings that differ from one another only
by case to map to the same "case-folded" form, even when those strings include
characters with complex case-mappings.

=head2 Use for Case-insensitive Comparison

Simply write C<fc($this) eq fc($that)> instead of C<lc($this) eq lc($that)>.
You can also use C<index> on case-folded strings for substring search.

=head2 Use for String Lookups

Frequently we want to store data in a hash, or a database, or an external file
for later retrieval. Sometimes we want to be able to match the keys in this
data case-insensitively -- that is, we should be able to store some data under
the key "hello" and later retrieve it with the key "HELLO". Some databases
have complete support for collation, but in other databases the support is
missing or broken, and Perl hashes don't support it at all. By making
case-folding part of the process you use to normalize your keys before using
them to access a database or data structure, you get case-insensitive lookup.

    $roles{fc "Samuel L. Jackson"} = ["Gin Rummy", "Nick Fury", "Mace Windu"];
    
    $roles = $roles{fc "Samuel l. JACKSON"}; # Gets the data.

=head1 EXPORTS

=head2 fc($str)

Exported by default when you use the module. C<use Unicode::CaseFold ()> or
C<use Unicode::CaseFold qw(case_fold !fc)> if you don't want it to be
exported.

Returns the case-folded version of C<$str>. This function is prototyped to act
as much as possible like the built-ins C<lc> and C<uc>; it imposes a scalar
context on its argument, and if called with no argument it will return the
case-folded version of C<$_>.

=head2 case_fold($str)

Exported on request. Just like C<fc>, except that it has no prototype and
won't case-fold C<$_> if called without an argument.

=head1 VARIABLES

=head2 $Unicode::CaseFolding::XS

Whether the XS extension is in use. The pure-perl implementation is 5-10 times
slower than the XS extension, and on versions of perl before 5.10.0 it can
sometimes produce sub-optimal case-foldings.

=head2 $Unicode::CaseFolding::LEGACY_MAPPING

Is set to true if the perl version is prior to 5.10.0 and the XS extension is
not available. In this case, C<fc> will produce incompatible case-foldings for
a few characters.

=head1 COMPATIBILITY

XXX Different Perl versions include different versions of the Unicode
database.

XXX LEGACY_MAPPING mode.

XXX Requires perl 5.8.1 or newer.


=head1 SEE ALSO

=over 4

=item *

L<http://unicode.org/reports/tr21/tr21-5.html>: Unicode Standard Annex #21: Case Mappings

=back
