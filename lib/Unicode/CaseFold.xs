#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#define PERL_VERSION_DECIMAL(r,v,s) (r*1000000 + v*1000 + s)
#define PERL_DECIMAL_VERSION \
    PERL_VERSION_DECIMAL(PERL_REVISION,PERL_VERSION,PERL_SUBVERSION)
#define PERL_VERSION_GE(r,v,s) \
    (PERL_DECIMAL_VERSION >= PERL_VERSION_DECIMAL(r,v,s))

#if PERL_VERSION_GE(5,9,2)
# define FOLDED_CHARSIZE UTF8_MAXBYTES_CASE
#else
# define FOLDED_CHARSIZE UTF8_MAXBYTES
#endif

MODULE = Unicode::CaseFold    PACKAGE = Unicode::CaseFold

PROTOTYPES: DISABLE

SV *
case_fold(str)
    SV *str
  CODE:
    STRLEN input_len, folded_len;
    U8 *in = SvPVutf8(str, input_len),
      *ptr,
      folded[FOLDED_CHARSIZE + 1];

    RETVAL = newSV(input_len); /* We may need more, but we won't need less. */
    SvPOK_only(RETVAL);
    SvUTF8_on(RETVAL);

    for ( ptr = in ; ptr < in + input_len ; ptr += UTF8SKIP(ptr) ) {
      to_utf8_fold(ptr, folded, &folded_len);
      sv_catpvn(RETVAL, folded, folded_len);
    }
  OUTPUT:
    RETVAL
