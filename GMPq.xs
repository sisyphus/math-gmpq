
#ifdef  __MINGW32__
#ifndef __USE_MINGW_ANSI_STDIO
#define __USE_MINGW_ANSI_STDIO 1
#endif
#endif

#define PERL_NO_GET_CONTEXT 1

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <stdio.h>
#include <stdlib.h>
#include <gmp.h>

#ifdef _MSC_VER
#pragma warning(disable:4700 4715 4716)
#endif

#if defined MATH_GMPQ_NEED_LONG_LONG_INT
#ifndef _MSC_VER
#include <inttypes.h>
#endif
#endif

#ifdef OLDPERL
#define SvUOK SvIsUV
#endif

#ifndef Newx
#  define Newx(v,n,t) New(0,v,n,t)
#endif

#ifndef Newxz
#  define Newxz(v,n,t) Newz(0,v,n,t)
#endif

void Rmpq_canonicalize (mpq_t * p) {
     mpq_canonicalize(*p);
}

SV * Rmpq_init(pTHX) {
     mpq_t * mpq_t_obj;
     SV * obj_ref, * obj;

     New(1, mpq_t_obj, 1, mpq_t);
     if(mpq_t_obj == NULL) croak("Failed to allocate memory in Rmpq_init function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::GMPq");
     mpq_init (*mpq_t_obj);

     sv_setiv(obj, INT2PTR(IV, mpq_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * Rmpq_init_nobless(pTHX) {
     mpq_t * mpq_t_obj;
     SV * obj_ref, * obj;

     New(1, mpq_t_obj, 1, mpq_t);
     if(mpq_t_obj == NULL) croak("Failed to allocate memory in Rmpq_init_nobless function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     mpq_init (*mpq_t_obj);

     sv_setiv(obj, INT2PTR(IV, mpq_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

void DESTROY(pTHX_ mpq_t * p) {
/*     printf("Destroying mpq "); */
     mpq_clear(*p);
     Safefree(p);
/*     printf("...destroyed\n"); */
}

void Rmpq_clear(pTHX_ mpq_t * p) {
     mpq_clear(*p);
     Safefree(p);
}

void Rmpq_clear_mpq(mpq_t * p) {
     mpq_clear(*p);
}

void Rmpq_clear_ptr(pTHX_ mpq_t * p) {
     Safefree(p);
}

void Rmpq_set(mpq_t * p1, mpq_t * p2) {
     mpq_set(*p1, *p2);
}

void Rmpq_swap(mpq_t * p1, mpq_t * p2) {
     mpq_swap(*p1, *p2);
}

void Rmpq_set_z(mpq_t * p1, mpz_t * p2) {
     mpq_set_z(*p1, *p2);
}

void Rmpq_set_ui(mpq_t * p1, unsigned long p2, unsigned long p3) {
     mpq_set_ui(*p1, p2, p3);
}

void Rmpq_set_si(mpq_t * p1, int p2, int p3) {
     mpq_set_si(*p1, p2, p3);
}

void Rmpq_set_str(pTHX_ mpq_t * p1, SV * p2, SV * base) {
     unsigned long b = SvUV(base);
     if(b == 1 || b > 62) croak ("%u is not a valid base in Rmpq_set_str", b);
     if(mpq_set_str(*p1, SvPV_nolen(p2), SvUV(base)))
       croak("String supplied to Rmpq_set_str function is not a valid base %u number", SvUV(base));
}


double Rmpq_get_d(mpq_t * p) {
     return mpq_get_d(*p);
}

void Rmpq_set_d(mpq_t * p, double d){
     mpq_set_d(*p, d);
}

void _Rmpq_set_ld(pTHX_ mpq_t * q, SV * p) {
#ifdef USE_LONG_DOUBLE
     char buffer[50];
     int exp, exp2 = 0;
     long double fr;

     fr = frexpl((long double)SvNV(p), &exp);

     while(fr != floorl(fr)) {
          fr *= 2;
          exp2 += 1;
     }

     sprintf(buffer, "%.0Lf", fr);

     mpq_set_str(*q, buffer, 10);

     if (exp2 > exp) mpq_div_2exp(*q, *q, exp2 - exp);
     else mpq_mul_2exp(*q, *q, exp - exp2);
#else
     croak("_Rmpq_set_ld not implemented on this build of perl");
#endif
}

void Rmpq_set_f(mpq_t * p, mpf_t * f) {
     mpq_set_f(*p, *f);
}

SV * Rmpq_get_str(pTHX_ mpq_t * p, SV * base){
     char * out;
     SV * outsv;
     unsigned long b = SvUV(base);

     New(123, out, mpz_sizeinbase(mpq_numref(*p), b) + mpz_sizeinbase(mpq_denref(*p), b) + 3, char);
     if(out == NULL) croak ("Failed to allocate memory in Rmpq_get_str function");

     mpq_get_str(out, b, *p);
     outsv = newSVpv(out, 0);
     Safefree(out);
     return outsv;
}

int Rmpq_cmp(mpq_t * p1, mpq_t * p2) {
     return mpq_cmp(*p1, *p2);
}

int Rmpq_cmp_ui(mpq_t * p1, unsigned long n, unsigned long d) {
     return mpq_cmp_ui(*p1, n, d);
}

int Rmpq_cmp_si(mpq_t * p1, long n, unsigned long d) {
     return mpq_cmp_si(*p1, n, d);
}

int Rmpq_cmp_z(mpq_t * p, mpz_t * z) {
#if __GNU_MP_RELEASE >= 60099
     return mpq_cmp_z(*p, *z);
#else
     croak("Rmpq_cmp_z not implemented in this version (%s) of gmp - need at least 6.1.0", gmp_version);
#endif
}

int Rmpq_sgn(mpq_t * p) {
     return mpq_sgn(*p);
}

int Rmpq_equal(mpq_t * p1, mpq_t * p2) {
     return mpq_equal(*p1, *p2);
}

void Rmpq_add(mpq_t * p1, mpq_t * p2, mpq_t * p3) {
     mpq_add(*p1, *p2, *p3);
}

void Rmpq_sub(mpq_t * p1, mpq_t * p2, mpq_t * p3) {
     mpq_sub(*p1, *p2, *p3);
}

void Rmpq_mul(mpq_t * p1, mpq_t * p2, mpq_t * p3) {
     mpq_mul(*p1, *p2, *p3);
}

void Rmpq_div(mpq_t * p1, mpq_t * p2, mpq_t * p3) {
     mpq_div(*p1, *p2, *p3);
}

void Rmpq_mul_2exp(pTHX_ mpq_t * p1, mpq_t * p2, SV * p3) {
     mpq_mul_2exp(*p1, *p2, SvUV(p3));
}

void Rmpq_div_2exp(pTHX_ mpq_t * p1, mpq_t * p2, SV * p3) {
     mpq_div_2exp(*p1, *p2, SvUV(p3));
}

void Rmpq_neg(mpq_t * p1, mpq_t * p2) {
     mpq_neg(*p1, *p2);
}

void Rmpq_abs(mpq_t * p1, mpq_t * p2) {
     mpq_abs(*p1, *p2);
}

void Rmpq_inv(mpq_t * p1, mpq_t * p2) {
     mpq_inv(*p1, *p2);
}

SV * _Rmpq_out_str(pTHX_ mpq_t * p, int base){
     size_t ret;
     if(base < 2 || base > 36)
       croak("2nd argument supplied to Rmpq_out_str is out of allowable range (must be between 2 and 36 inclusive)");
     ret = mpq_out_str(NULL, base, *p);
     fflush(stdout);
     return newSVuv(ret);
}

SV * _Rmpq_out_strS(pTHX_ mpq_t * p, int base, SV * suff) {
     size_t ret;
     if(base < 2 || base > 36)
       croak("2nd argument supplied to Rmpq_out_str is out of allowable range (must be between 2 and 36 inclusive)");
     ret = mpq_out_str(NULL, base, *p);
     printf("%s", SvPV_nolen(suff));
     fflush(stdout);
     return newSVuv(ret);
}

SV * _Rmpq_out_strP(pTHX_ SV * pre, mpq_t * p, int base) {
     size_t ret;
     if(base < 2 || base > 36)
       croak("2nd argument supplied to Rmpq_out_str is out of allowable range (must be between 2 and 36 inclusive)");
     printf("%s", SvPV_nolen(pre));
     ret = mpq_out_str(NULL, base, *p);
     fflush(stdout);
     return newSVuv(ret);
}

SV * _Rmpq_out_strPS(pTHX_ SV * pre, mpq_t * p, int base, SV * suff) {
     size_t ret;
     if(base < 2 || base > 36)
       croak("2nd argument supplied to Rmpq_out_str is out of allowable range (must be between 2 and 36 inclusive)");
     printf("%s", SvPV_nolen(pre));
     ret = mpq_out_str(NULL, base, *p);
     printf("%s", SvPV_nolen(suff));
     fflush(stdout);
     return newSVuv(ret);
}



SV * _TRmpq_out_str(pTHX_ FILE * stream, int base, mpq_t * p) {
     size_t ret;
     ret = mpq_out_str(stream, base, *p);
     fflush(stream);
     return newSVuv(ret);
}

SV * _TRmpq_out_strS(pTHX_ FILE * stream, int base, mpq_t * p, SV * suff) {
     size_t ret;
     ret = mpq_out_str(stream, base, *p);
     fflush(stream);
     fprintf(stream, "%s", SvPV_nolen(suff));
     fflush(stream);
     return newSVuv(ret);
}

SV * _TRmpq_out_strP(pTHX_ SV * pre, FILE * stream, int base, mpq_t * p) {
     size_t ret;
     fprintf(stream, "%s", SvPV_nolen(pre));
     fflush(stream);
     ret = mpq_out_str(stream, base, *p);
     fflush(stream);
     return newSVuv(ret);
}

SV * _TRmpq_out_strPS(pTHX_ SV * pre, FILE * stream, int base, mpq_t * p, SV * suff) {
     size_t ret;
     fprintf(stream, "%s", SvPV_nolen(pre));
     fflush(stream);
     ret = mpq_out_str(stream, base, *p);
     fflush(stream);
     fprintf(stream, "%s", SvPV_nolen(suff));
     fflush(stream);
     return newSVuv(ret);
}

SV * TRmpq_inp_str(pTHX_ mpq_t * p, FILE * stream, SV * base) {
     size_t ret;
     ret = mpq_inp_str(*p, stream, (int)SvIV(base));
     /* fflush(stream); */
     return newSVuv(ret);
}

SV * Rmpq_inp_str(pTHX_ mpq_t * p, int base){
     size_t ret;
     ret = mpq_inp_str(*p, NULL, base);
     /* fflush(stdin); */
     return newSVuv(ret);
}

void Rmpq_numref(mpz_t * z, mpq_t * r) {
     mpz_set(*z, mpq_numref(*r));
}

void Rmpq_denref(mpz_t * z, mpq_t * r) {
     mpz_set(*z, mpq_denref(*r));
}

void Rmpq_get_num(mpz_t * z, mpq_t * r) {
     mpq_get_num(*z, *r);
}

void Rmpq_get_den(mpz_t * z, mpq_t * r) {
     mpq_get_den(*z, *r);
}

void Rmpq_set_num(mpq_t * r, mpz_t * z) {
     mpq_set_num(*r, *z);
}

void Rmpq_set_den(mpq_t * r, mpz_t * z) {
     mpq_set_den(*r, *z);
}

SV * get_refcnt(pTHX_ SV * s) {
     return newSVuv(SvREFCNT(s));
}

/* Finish typemapping - typemap 1st arg only */

SV * overload_mul(pTHX_ SV * a, SV * b, SV * third) {
     mpq_t * mpq_t_obj;
     SV * obj_ref, * obj;
     const char * h;

     if(sv_isobject(b)) h = HvNAME(SvSTASH(SvRV(b)));

     if(!sv_isobject(b) || strNE(h, "Math::MPFR")) {
       New(1, mpq_t_obj, 1, mpq_t);
       if(mpq_t_obj == NULL) croak("Failed to allocate memory in overload_mul function");
       obj_ref = newSV(0);
       obj = newSVrv(obj_ref, "Math::GMPq");
       mpq_init(*mpq_t_obj);
       sv_setiv(obj, INT2PTR(IV, mpq_t_obj));
       SvREADONLY_on(obj);
     }

#ifndef MATH_GMPQ_NEED_LONG_LONG_INT
     if(SvIOK(b)) {
       mpq_set_d(*mpq_t_obj, SvNV(b));
       mpq_mul(*mpq_t_obj, *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *mpq_t_obj);
       return obj_ref;
     }
#else
     if(SvIOK(b)) {
       if(mpq_set_str(*mpq_t_obj, SvPV_nolen(b), 0))
         croak("Invalid string supplied to Math::GMPq::overload_mul");
       mpq_mul(*mpq_t_obj, *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *mpq_t_obj);
       return obj_ref;
     }
#endif

     if(SvNOK(b)) {
#ifdef USE_LONG_DOUBLE
       _Rmpq_set_ld(aTHX_ mpq_t_obj, b);
#else
       mpq_set_d(*mpq_t_obj, SvNV(b));
#endif
       mpq_mul(*mpq_t_obj, *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *mpq_t_obj);
       return obj_ref;
     }

     if(SvPOK(b)) {
       if(mpq_set_str(*mpq_t_obj, SvPV_nolen(b), 0))
         croak("Invalid string supplied to Math::GMPq::overload_mul");
       mpq_canonicalize(*mpq_t_obj);
       mpq_mul(*mpq_t_obj, *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *mpq_t_obj);
       return obj_ref;
     }

     if(sv_isobject(b)) {
       if(strEQ(h, "Math::GMPq")) {
         mpq_mul(*mpq_t_obj, *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *(INT2PTR(mpq_t *, SvIV(SvRV(b)))));
         return obj_ref;
       }
       if(strEQ(h, "Math::MPFR")) {
         dSP;
         SV * ret;
         int count;

         ENTER;

         PUSHMARK(SP);
         XPUSHs(b);
         XPUSHs(a);
         XPUSHs(sv_2mortal(newSViv(1)));
         PUTBACK;

         count = call_pv("Math::MPFR::overload_mul", G_SCALAR);

         SPAGAIN;

         if (count != 1)
           croak("Error in Math::GMPq::overload_mul callback to Math::MPFR::overload_mul\n");

         ret = POPs;

         /* Avoid "Attempt to free unreferenced scalar" warning */
         SvREFCNT_inc(ret);
         LEAVE;
         return ret;
       }
     }

     croak("Invalid argument supplied to Math::GMPq::overload_mul");
}

SV * overload_add(pTHX_ SV * a, SV * b, SV * third) {
     mpq_t * mpq_t_obj;
     SV * obj_ref, * obj;
     const char *h;

     if(sv_isobject(b)) h = HvNAME(SvSTASH(SvRV(b)));

     if(!sv_isobject(b) || strNE(h, "Math::MPFR")) {
       New(1, mpq_t_obj, 1, mpq_t);
       if(mpq_t_obj == NULL) croak("Failed to allocate memory in overload_add function");
       obj_ref = newSV(0);
       obj = newSVrv(obj_ref, "Math::GMPq");
       mpq_init(*mpq_t_obj);
       sv_setiv(obj, INT2PTR(IV, mpq_t_obj));
       SvREADONLY_on(obj);
     }

#ifndef MATH_GMPQ_NEED_LONG_LONG_INT
     if(SvIOK(b)) {
       mpq_set_d(*mpq_t_obj, SvNV(b));
       mpq_add(*mpq_t_obj, *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *mpq_t_obj);
       return obj_ref;
     }
#else
     if(SvIOK(b)) {
       if(mpq_set_str(*mpq_t_obj, SvPV_nolen(b), 0))
         croak("Invalid string supplied to Math::GMPq::overload_add");
       mpq_add(*mpq_t_obj, *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *mpq_t_obj);
       return obj_ref;
     }
#endif

     if(SvNOK(b)) {
#ifdef USE_LONG_DOUBLE
       _Rmpq_set_ld(aTHX_ mpq_t_obj, b);
#else
       mpq_set_d(*mpq_t_obj, SvNV(b));
#endif
       mpq_add(*mpq_t_obj, *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *mpq_t_obj);
       return obj_ref;
     }


     if(SvPOK(b)) {
       if(mpq_set_str(*mpq_t_obj, SvPV_nolen(b), 0))
         croak("Invalid string supplied to Math::GMPq::overload_add");
       mpq_canonicalize(*mpq_t_obj);
       mpq_add(*mpq_t_obj, *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *mpq_t_obj);
       return obj_ref;
     }

     if(sv_isobject(b)) {
       if(strEQ(h, "Math::GMPq")) {
         mpq_add(*mpq_t_obj, *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *(INT2PTR(mpq_t *, SvIV(SvRV(b)))));
         return obj_ref;
       }
       if(strEQ(h, "Math::MPFR")) {
         dSP;
         SV * ret;
         int count;

         ENTER;

         PUSHMARK(SP);
         XPUSHs(b);
         XPUSHs(a);
         XPUSHs(sv_2mortal(newSViv(1)));
         PUTBACK;

         count = call_pv("Math::MPFR::overload_add", G_SCALAR);

         SPAGAIN;

         if (count != 1)
           croak("Error in Math::GMPq::overload_add callback to Math::MPFR::overload_add\n");

         ret = POPs;

         /* Avoid "Attempt to free unreferenced scalar" warning */
         SvREFCNT_inc(ret);
         LEAVE;
         return ret;
       }
     }

     croak("Invalid argument supplied to Math::GMPq::overload_add");
}

SV * overload_sub(pTHX_ SV * a, SV * b, SV * third) {
     mpq_t * mpq_t_obj;
     SV * obj_ref, * obj;
     const char *h;

     if(sv_isobject(b)) h = HvNAME(SvSTASH(SvRV(b)));

     if(!sv_isobject(b) || strNE(h, "Math::MPFR")) {
       New(1, mpq_t_obj, 1, mpq_t);
       if(mpq_t_obj == NULL) croak("Failed to allocate memory in overload_sub function");
       obj_ref = newSV(0);
       obj = newSVrv(obj_ref, "Math::GMPq");
       mpq_init(*mpq_t_obj);
       sv_setiv(obj, INT2PTR(IV, mpq_t_obj));
       SvREADONLY_on(obj);
     }

#ifndef MATH_GMPQ_NEED_LONG_LONG_INT
     if(SvIOK(b)) {
       mpq_set_d(*mpq_t_obj, SvNV(b));
       if(third == &PL_sv_yes) mpq_sub(*mpq_t_obj, *mpq_t_obj, *(INT2PTR(mpq_t *, SvIV(SvRV(a)))));
       else mpq_sub(*mpq_t_obj, *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *mpq_t_obj);
       return obj_ref;
     }
#else
     if(SvIOK(b)) {
       if(mpq_set_str(*mpq_t_obj, SvPV_nolen(b), 0))
         croak("Invalid string supplied to Math::GMPq::overload_sub");
       if(third == &PL_sv_yes) mpq_sub(*mpq_t_obj, *mpq_t_obj, *(INT2PTR(mpq_t *, SvIV(SvRV(a)))));
       else mpq_sub(*mpq_t_obj, *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *mpq_t_obj);
       return obj_ref;
     }
#endif

     if(SvNOK(b)) {
#ifdef USE_LONG_DOUBLE
       _Rmpq_set_ld(aTHX_ mpq_t_obj, b);
#else
       mpq_set_d(*mpq_t_obj, SvNV(b));
#endif
       if(third == &PL_sv_yes) mpq_sub(*mpq_t_obj, *mpq_t_obj, *(INT2PTR(mpq_t *, SvIV(SvRV(a)))));
       else mpq_sub(*mpq_t_obj, *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *mpq_t_obj);
       return obj_ref;
     }

     if(SvPOK(b)) {
       if(mpq_set_str(*mpq_t_obj, SvPV_nolen(b), 0))
         croak("Invalid string supplied to Math::GMPq::overload_sub");
       mpq_canonicalize(*mpq_t_obj);
       if(third == &PL_sv_yes) mpq_sub(*mpq_t_obj, *mpq_t_obj, *(INT2PTR(mpq_t *, SvIV(SvRV(a)))));
       else mpq_sub(*mpq_t_obj, *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *mpq_t_obj);
       return obj_ref;
     }

     if(sv_isobject(b)) {
       if(strEQ(h, "Math::GMPq")) {
         mpq_sub(*mpq_t_obj, *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *(INT2PTR(mpq_t *, SvIV(SvRV(b)))));
         return obj_ref;
       }
       if(strEQ(h, "Math::MPFR")) {
         dSP;
         SV * ret;
         int count;

         ENTER;

         PUSHMARK(SP);
         XPUSHs(b);
         XPUSHs(a);
         XPUSHs(sv_2mortal(&PL_sv_yes));
         PUTBACK;

         count = call_pv("Math::MPFR::overload_sub", G_SCALAR);

         SPAGAIN;

         if (count != 1)
           croak("Error in Math::GMPq::overload_sub callback to Math::MPFR::overload_sub\n");

         ret = POPs;

         /* Avoid "Attempt to free unreferenced scalar" warning */
         SvREFCNT_inc(ret);
         LEAVE;
         return ret;
       }
     }

     croak("Invalid argument supplied to Math::GMPq::overload_sub function");

}

SV * overload_div(pTHX_ SV * a, SV * b, SV * third) {
     mpq_t * mpq_t_obj;
     SV * obj_ref, * obj;
     const char *h;

     if(sv_isobject(b)) h = HvNAME(SvSTASH(SvRV(b)));

     if(!sv_isobject(b) || strNE(h, "Math::MPFR")) {
       New(1, mpq_t_obj, 1, mpq_t);
       if(mpq_t_obj == NULL) croak("Failed to allocate memory in overload_div function");
       obj_ref = newSV(0);
       obj = newSVrv(obj_ref, "Math::GMPq");
       mpq_init(*mpq_t_obj);
       sv_setiv(obj, INT2PTR(IV, mpq_t_obj));
       SvREADONLY_on(obj);
     }

#ifndef MATH_GMPQ_NEED_LONG_LONG_INT
     if(SvIOK(b)) {
       mpq_set_d(*mpq_t_obj, SvNV(b));
       if(third == &PL_sv_yes) mpq_div(*mpq_t_obj, *mpq_t_obj, *(INT2PTR(mpq_t *, SvIV(SvRV(a)))));
       else mpq_div(*mpq_t_obj, *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *mpq_t_obj);
       return obj_ref;
     }
#else
     if(SvIOK(b)) {
       if(mpq_set_str(*mpq_t_obj, SvPV_nolen(b), 0))
         croak("Invalid string supplied to Math::GMPq::overload_div");
       if(third == &PL_sv_yes) mpq_div(*mpq_t_obj, *mpq_t_obj, *(INT2PTR(mpq_t *, SvIV(SvRV(a)))));
       else mpq_div(*mpq_t_obj, *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *mpq_t_obj);
       return obj_ref;
     }
#endif

     if(SvNOK(b)) {
#ifdef USE_LONG_DOUBLE
       _Rmpq_set_ld(aTHX_ mpq_t_obj, b);
#else
       mpq_set_d(*mpq_t_obj, SvNV(b));
#endif
       if(third == &PL_sv_yes) mpq_div(*mpq_t_obj, *mpq_t_obj, *(INT2PTR(mpq_t *, SvIV(SvRV(a)))));
       else mpq_div(*mpq_t_obj, *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *mpq_t_obj);
       return obj_ref;
     }


     if(SvPOK(b)) {
       if(mpq_set_str(*mpq_t_obj, SvPV_nolen(b), 0))
         croak("Invalid string supplied to Math::GMPq::overload_div");
       mpq_canonicalize(*mpq_t_obj);
       if(third == &PL_sv_yes) mpq_div(*mpq_t_obj, *mpq_t_obj, *(INT2PTR(mpq_t *, SvIV(SvRV(a)))));
       else mpq_div(*mpq_t_obj, *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *mpq_t_obj);
       return obj_ref;
     }

     if(sv_isobject(b)) {
       if(strEQ(h, "Math::GMPq")) {
         mpq_div(*mpq_t_obj, *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *(INT2PTR(mpq_t *, SvIV(SvRV(b)))));
         return obj_ref;
       }
       if(strEQ(h, "Math::MPFR")) {
         dSP;
         SV * ret;
         int count;

         ENTER;

         PUSHMARK(SP);
         XPUSHs(b);
         XPUSHs(a);
         XPUSHs(sv_2mortal(&PL_sv_yes));
         PUTBACK;

         count = call_pv("Math::MPFR::overload_div", G_SCALAR);

         SPAGAIN;

         if (count != 1)
           croak("Error in Math::GMPq::overload_div callback to Math::MPFR::overload_div\n");

         ret = POPs;

         /* Avoid "Attempt to free unreferenced scalar" warning */
         SvREFCNT_inc(ret);
         LEAVE;
         return ret;
       }
     }

     croak("Invalid argument supplied to Math::GMPq::overload_div function");

}

SV * overload_string(pTHX_ mpq_t * p, SV * second, SV * third) {
     char * out;
     SV * outsv;

     New(123, out, mpz_sizeinbase(mpq_numref(*p), 10) + mpz_sizeinbase(mpq_denref(*p), 10) + 3, char);
     if(out == NULL) croak ("Failed to allocate memory in overload_string function");

     mpq_get_str(out, 10, *p);
     outsv = newSVpv(out, 0);
     Safefree(out);
     return outsv;
}

SV * overload_copy(pTHX_ mpq_t * p, SV * second, SV * third) {
     mpq_t * mpq_t_obj;
     SV * obj_ref, * obj;

     New(1, mpq_t_obj, 1, mpq_t);
     if(mpq_t_obj == NULL) croak("Failed to allocate memory in overload_copy function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::GMPq");

     mpq_init(*mpq_t_obj);
     mpq_set(*mpq_t_obj, *p);
     sv_setiv(obj, INT2PTR(IV, mpq_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * overload_abs(pTHX_ mpq_t * p, SV * second, SV * third) {
     mpq_t * mpq_t_obj;
     SV * obj_ref, * obj;

     New(1, mpq_t_obj, 1, mpq_t);
     if(mpq_t_obj == NULL) croak("Failed to allocate memory in overload_abs function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::GMPq");
     mpq_init(*mpq_t_obj);

     mpq_abs(*mpq_t_obj, *p);
     sv_setiv(obj, INT2PTR(IV, mpq_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * overload_gt(pTHX_ mpq_t * a, SV * b, SV * third) {
     mpq_t t;
     int ret;

#ifdef MATH_GMPQ_NEED_LONG_LONG_INT
     if(SvIOK(b)) {
       mpq_init(t);
       if(mpq_set_str(t, SvPV_nolen(b), 0))
         croak("Invalid string supplied to Math::GMPq::overload_gt");
       ret = mpq_cmp(*a, t);
       mpq_clear(t);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret > 0) return newSViv(1);
       return newSViv(0);
     }
#else
     if(SvUOK(b)) {
       ret = mpq_cmp_ui(*a, SvUV(b), 1);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret > 0) return newSViv(1);
       return newSViv(0);
     }

     if(SvIOK(b)) {
       ret = mpq_cmp_si(*a, SvIV(b), 1);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret > 0) return newSViv(1);
       return newSViv(0);
     }
#endif

     if(SvNOK(b)) {
       mpq_init(t);
#ifdef USE_LONG_DOUBLE
       _Rmpq_set_ld(aTHX_ &t, b);
#else
       mpq_set_d(t, SvNV(b));
#endif
       ret = mpq_cmp(*a, t);
       mpq_clear(t);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret > 0) return newSViv(1);
       return newSViv(0);
     }

     if(SvPOK(b)) {
       mpq_init(t);
       if(mpq_set_str(t, SvPV_nolen(b), 0))
         croak("Invalid string supplied to Math::GMPq::overload_gt");
       mpq_canonicalize(t);
       ret = mpq_cmp(*a, t);
       mpq_clear(t);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret > 0) return newSViv(1);
       return newSViv(0);
     }

     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::GMPq")) {
         ret = mpq_cmp(*a, *(INT2PTR(mpq_t *, SvIV(SvRV(b)))));
         if(ret > 0) return newSViv(1);
         return newSViv(0);
       }

       if(strEQ(h, "Math::GMPz")) {
#if __GNU_MP_RELEASE < 60099
         croak("overloading \">\": Rmpq_cmp_z not implemented in this version (%s) of gmp - need at least 6.1.0", gmp_version);
#else
         ret = mpq_cmp_z(*a, *(INT2PTR(mpz_t *, SvIV(SvRV(b)))));
         if(ret > 0) return newSViv(1);
         return newSViv(0);
#endif
       }
     }

     croak("Invalid argument supplied to Math::GMPq::overload_gt");
}

SV * overload_gte(pTHX_ mpq_t * a, SV * b, SV * third) {
     mpq_t t;
     int ret;

#ifdef MATH_GMPQ_NEED_LONG_LONG_INT
     if(SvIOK(b)) {
       mpq_init(t);
       if(mpq_set_str(t, SvPV_nolen(b), 0))
         croak("Invalid string supplied to Math::GMPq::overload_gte");
       ret = mpq_cmp(*a, t);
       mpq_clear(t);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret >= 0) return newSViv(1);
       return newSViv(0);
     }
#else
     if(SvUOK(b)) {
       ret = mpq_cmp_ui(*a, SvUV(b), 1);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret >= 0) return newSViv(1);
       return newSViv(0);
     }

     if(SvIOK(b)) {
       ret = mpq_cmp_si(*a, SvIV(b), 1);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret >= 0) return newSViv(1);
       return newSViv(0);
     }
#endif

     if(SvNOK(b)) {
       mpq_init(t);
#ifdef USE_LONG_DOUBLE
       _Rmpq_set_ld(aTHX_ &t, b);
#else
       mpq_set_d(t, SvNV(b));
#endif
       ret = mpq_cmp(*a, t);
       mpq_clear(t);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret >= 0) return newSViv(1);
       return newSViv(0);
     }

     if(SvPOK(b)) {
       mpq_init(t);
       if(mpq_set_str(t, SvPV_nolen(b), 0))
         croak("Invalid string supplied to Math::GMPq::overload_gte");
       mpq_canonicalize(t);
       ret = mpq_cmp(*a, t);
       mpq_clear(t);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret >= 0) return newSViv(1);
       return newSViv(0);
     }

     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::GMPq")) {
         ret = mpq_cmp(*a, *(INT2PTR(mpq_t *, SvIV(SvRV(b)))));
         if(ret >= 0) return newSViv(1);
         return newSViv(0);
       }

       if(strEQ(h, "Math::GMPz")) {
#if __GNU_MP_RELEASE < 60099
         croak("overloading \">=\": Rmpq_cmp_z not implemented in this version (%s) of gmp - need at least 6.1.0", gmp_version);
#else
         ret = mpq_cmp_z(*a, *(INT2PTR(mpz_t *, SvIV(SvRV(b)))));
         if(ret >= 0) return newSViv(1);
         return newSViv(0);
#endif
       }
     }

     croak("Invalid argument supplied to Math::GMPq::overload_gte");
}

SV * overload_lt(pTHX_ mpq_t * a, SV * b, SV * third) {
     mpq_t t;
     int ret;

#ifdef MATH_GMPQ_NEED_LONG_LONG_INT
     if(SvIOK(b)) {
       mpq_init(t);
       if(mpq_set_str(t, SvPV_nolen(b), 0))
         croak("Invalid string supplied to Math::GMPq::overload_lt");
       ret = mpq_cmp(*a, t);
       mpq_clear(t);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret < 0) return newSViv(1);
       return newSViv(0);
     }
#else
     if(SvUOK(b)) {
       ret = mpq_cmp_ui(*a, SvUV(b), 1);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret < 0) return newSViv(1);
       return newSViv(0);
     }

     if(SvIOK(b)) {
       ret = mpq_cmp_si(*a, SvIV(b), 1);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret < 0) return newSViv(1);
       return newSViv(0);
     }
#endif

     if(SvNOK(b)) {
       mpq_init(t);
#ifdef USE_LONG_DOUBLE
       _Rmpq_set_ld(aTHX_ &t, b);
#else
       mpq_set_d(t, SvNV(b));
#endif
       ret = mpq_cmp(*a, t);
       mpq_clear(t);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret < 0) return newSViv(1);
       return newSViv(0);
     }

     if(SvPOK(b)) {
       mpq_init(t);
       if(mpq_set_str(t, SvPV_nolen(b), 0))
         croak("Invalid string supplied to Math::GMPq::overload_lt");
       mpq_canonicalize(t);
       ret = mpq_cmp(*a, t);
       mpq_clear(t);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret < 0) return newSViv(1);
       return newSViv(0);
     }

     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::GMPq")) {
         ret = mpq_cmp(*a, *(INT2PTR(mpq_t *, SvIV(SvRV(b)))));
         if(ret < 0) return newSViv(1);
         return newSViv(0);
       }

       if(strEQ(h, "Math::GMPz")) {
#if __GNU_MP_RELEASE < 60099
         croak("overloading \"<\": Rmpq_cmp_z not implemented in this version (%s) of gmp - need at least 6.1.0", gmp_version);
#else
         ret = mpq_cmp_z(*a, *(INT2PTR(mpz_t *, SvIV(SvRV(b)))));
         if(ret < 0) return newSViv(1);
         return newSViv(0);
#endif
       }
     }

     croak("Invalid argument supplied to Math::GMPq::overload_lt");
}

SV * overload_lte(pTHX_ mpq_t * a, SV * b, SV * third) {
     mpq_t t;
     int ret;

#ifdef MATH_GMPQ_NEED_LONG_LONG_INT
     if(SvIOK(b)) {
       mpq_init(t);
       if(mpq_set_str(t, SvPV_nolen(b), 0))
         croak("Invalid string supplied to Math::GMPq::overload_lte");
       ret = mpq_cmp(*a, t);
       mpq_clear(t);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret <= 0) return newSViv(1);
       return newSViv(0);
     }
#else
     if(SvUOK(b)) {
       ret = mpq_cmp_ui(*a, SvUV(b), 1);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret <= 0) return newSViv(1);
       return newSViv(0);
     }

     if(SvIOK(b)) {
       ret = mpq_cmp_si(*a, SvIV(b), 1);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret <= 0) return newSViv(1);
       return newSViv(0);
     }
#endif

     if(SvNOK(b)) {
       mpq_init(t);
#ifdef USE_LONG_DOUBLE
       _Rmpq_set_ld(aTHX_ &t, b);
#else
       mpq_set_d(t, SvNV(b));
#endif
       ret = mpq_cmp(*a, t);
       mpq_clear(t);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret <= 0) return newSViv(1);
       return newSViv(0);
     }

     if(SvPOK(b)) {
       mpq_init(t);
       if(mpq_set_str(t, SvPV_nolen(b), 0))
         croak("Invalid string supplied to Math::GMPq::overload_lte");
       mpq_canonicalize(t);
       ret = mpq_cmp(*a, t);
       mpq_clear(t);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret <= 0) return newSViv(1);
       return newSViv(0);
     }

     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::GMPq")) {
         ret = mpq_cmp(*a, *(INT2PTR(mpq_t *, SvIV(SvRV(b)))));
         if(ret <= 0) return newSViv(1);
         return newSViv(0);
       }

       if(strEQ(h, "Math::GMPz")) {
#if __GNU_MP_RELEASE < 60099
         croak("overloading \"<=\": Rmpq_cmp_z not implemented in this version (%s) of gmp - need at least 6.1.0", gmp_version);
#else
         ret = mpq_cmp_z(*a, *(INT2PTR(mpz_t *, SvIV(SvRV(b)))));
         if(ret <= 0) return newSViv(1);
         return newSViv(0);
#endif
       }

     }

     croak("Invalid argument supplied to Math::GMPq::overload_lte");
}

SV * overload_spaceship(pTHX_ mpq_t * a, SV * b, SV * third) {
     mpq_t t;
     int ret;

#ifdef MATH_GMPQ_NEED_LONG_LONG_INT
     if(SvIOK(b)) {
       mpq_init(t);
       if(mpq_set_str(t, SvPV_nolen(b), 0))
         croak("Invalid string supplied to Math::GMPq::overload_spaceship");
       ret = mpq_cmp(*a, t);
       mpq_clear(t);
       if(third == &PL_sv_yes) ret *= -1;
       return newSViv(ret);
     }
#else
     if(SvUOK(b)) {
       ret = mpq_cmp_ui(*a, SvUV(b), 1);
       if(third == &PL_sv_yes) ret *= -1;
       return newSViv(ret);
     }

     if(SvIOK(b)) {
       ret = mpq_cmp_si(*a, SvIV(b), 1);
       if(third == &PL_sv_yes) ret *= -1;
       return newSViv(ret);
     }
#endif

     if(SvNOK(b)) {
       mpq_init(t);
#ifdef USE_LONG_DOUBLE
       _Rmpq_set_ld(aTHX_ &t, b);
#else
       mpq_set_d(t, SvNV(b));
#endif
       ret = mpq_cmp(*a, t);
       mpq_clear(t);
       if(third == &PL_sv_yes) ret *= -1;
       return newSViv(ret);
     }

     if(SvPOK(b)) {
       mpq_init(t);
       if(mpq_set_str(t, SvPV_nolen(b), 0))
         croak("Invalid string supplied to Math::GMPq::overload_spaceship");
       mpq_canonicalize(t);
       ret = mpq_cmp(*a, t);
       mpq_clear(t);
       if(third == &PL_sv_yes) ret *= -1;
       return newSViv(ret);
     }

     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::GMPq")) {
         ret = mpq_cmp(*a, *(INT2PTR(mpq_t *, SvIV(SvRV(b)))));
         return newSViv(ret);
       }
       if(strEQ(h, "Math::GMPz")) {
#if __GNU_MP_RELEASE < 60099
         croak("overloading \"<=>\": Rmpq_cmp_z not implemented in this version (%s) of gmp - need at least 6.1.0", gmp_version);
#else
         ret = mpq_cmp_z(*a, *(INT2PTR(mpz_t *, SvIV(SvRV(b)))));
         return newSViv(ret);
#endif
       }
     }

     croak("Invalid argument supplied to Math::GMPq::overload_spaceship");
}

SV * overload_equiv(pTHX_ mpq_t * a, SV * b, SV * third) {
     mpq_t t;
     int ret;

#ifdef MATH_GMPQ_NEED_LONG_LONG_INT
     if(SvIOK(b)) {
       mpq_init(t);
       if(mpq_set_str(t, SvPV_nolen(b), 0))
         croak("Invalid string supplied to Math::GMPq::overload_equiv");
       ret = mpq_equal(*a, t);
       mpq_clear(t);
       return newSViv(ret);
     }
#else
     if(SvUOK(b)) {
       ret = mpq_cmp_ui(*a, SvUV(b), 1);
       if(ret == 0) return newSViv(1);
       return newSViv(0);
     }

     if(SvIOK(b)) {
       ret = mpq_cmp_si(*a, SvIV(b), 1);
       if(ret == 0) return newSViv(1);
       return newSViv(0);
     }
#endif

     if(SvNOK(b)) {
       mpq_init(t);
#ifdef USE_LONG_DOUBLE
       _Rmpq_set_ld(aTHX_ &t, b);
#else
       mpq_set_d(t, SvNV(b));
#endif
       ret = mpq_equal(*a, t);
       mpq_clear(t);
       return newSViv(ret);
     }

     if(SvPOK(b)) {
       mpq_init(t);
       if(mpq_set_str(t, SvPV_nolen(b), 0))
         croak("Invalid string supplied to Math::GMPq::overload_equiv");
       mpq_canonicalize(t);
       ret = mpq_equal(*a, t);
       mpq_clear(t);
       return newSViv(ret);
     }

     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::GMPq")) {
         return newSViv(mpq_equal(*a, *(INT2PTR(mpq_t *, SvIV(SvRV(b))))));
       }

       if(strEQ(h, "Math::GMPz")) {
#if __GNU_MP_RELEASE < 60099
         croak("overloading \"==\": Rmpq_cmp_z not implemented in this version (%s) of gmp - need at least 6.1.0", gmp_version);
#else
         if(mpq_cmp_z(*a, *(INT2PTR(mpz_t *, SvIV(SvRV(b)))))) return newSViv(0);
         return newSViv(1);
#endif
       }
     }

     croak("Invalid argument supplied to Math::GMPq::overload_equiv");
}

SV * overload_not_equiv(pTHX_ mpq_t * a, SV * b, SV * third) {
     mpq_t t;
     int ret;

#ifdef MATH_GMPQ_NEED_LONG_LONG_INT
     if(SvIOK(b)) {
       mpq_init(t);
       if(mpq_set_str(t, SvPV_nolen(b), 0))
         croak("Invalid string supplied to Math::GMPq::overload_not_equiv");
       ret = mpq_equal(*a, t);
       mpq_clear(t);
       if(ret) return newSViv(0);
       return newSViv(1);
     }
#else
     if(SvUOK(b)) {
       ret = mpq_cmp_ui(*a, SvUV(b), 1);
       if(ret != 0) return newSViv(1);
       return newSViv(0);
     }

     if(SvIOK(b)) {
       ret = mpq_cmp_si(*a, SvIV(b), 1);
       if(ret != 0) return newSViv(1);
       return newSViv(0);
     }
#endif

     if(SvNOK(b)) {
       mpq_init(t);
#ifdef USE_LONG_DOUBLE
       _Rmpq_set_ld(aTHX_ &t, b);
#else
       mpq_set_d(t, SvNV(b));
#endif
       ret = mpq_equal(*a, t);
       mpq_clear(t);
       if(ret) return newSViv(0);
       return newSViv(1);
     }

     if(SvPOK(b)) {
       mpq_init(t);
       if(mpq_set_str(t, SvPV_nolen(b), 0))
         croak("Invalid string supplied to Math::GMPq::overload_not_equiv");
       mpq_canonicalize(t);
       ret = mpq_equal(*a, t);
       mpq_clear(t);
       if(ret) return newSViv(0);
       return newSViv(1);
     }

     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::GMPq")) {
         ret = mpq_equal(*a, *(INT2PTR(mpq_t *, SvIV(SvRV(b)))));
         if(ret) return newSViv(0);
         return newSViv(1);
       }

       if(strEQ(h, "Math::GMPz")) {
#if __GNU_MP_RELEASE < 60099
         croak("overloading \"!=\": Rmpq_cmp_z not implemented in this version (%s) of gmp - need at least 6.1.0", gmp_version);
#else
         if(mpq_cmp_z(*a, *(INT2PTR(mpz_t *, SvIV(SvRV(b)))))) return newSViv(1);
         return newSViv(0);
#endif
       }
     }

     croak("Invalid argument supplied to Math::GMPq::overload_not_equiv");
}

SV * overload_not(pTHX_ mpq_t * a, SV * second, SV * third) {
     if(mpq_cmp_ui(*a, 0, 1)) return newSViv(0);
     return newSViv(1);
}

SV * overload_int(pTHX_ mpq_t * p, SV * second, SV * third) {
     mpz_t z_num, z_den;
     mpq_t * mpq_t_obj;
     SV * obj_ref, * obj;

     New(1, mpq_t_obj, 1, mpq_t);
     if(mpq_t_obj == NULL) croak("Failed to allocate memory in overload_int function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::GMPq");
     mpq_init(*mpq_t_obj);

     mpz_init(z_num);
     mpz_init(z_den);

     mpz_set(z_num, mpq_numref(*p));
     mpz_set(z_den, mpq_denref(*p));

     mpz_tdiv_q(z_num, z_num, z_den);
     mpq_set_z(*mpq_t_obj, z_num);

     sv_setiv(obj, INT2PTR(IV, mpq_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

/* Finish typemapping */

SV * overload_mul_eq(pTHX_ SV * a, SV * b, SV * third) {
     mpq_t t;

     SvREFCNT_inc(a);

#ifndef MATH_GMPQ_NEED_LONG_LONG_INT
     if(SvIOK(b)) {
       mpq_init(t);
       mpq_set_d(t, SvNV(b));
       mpq_mul(*(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), t);
       mpq_clear(t);
       return a;
       }
#else
     if(SvIOK(b)) {
       mpq_init(t);
       if(mpq_set_str(t, SvPV_nolen(b), 0)) {
         SvREFCNT_dec(a);
         croak("Invalid string supplied to Math::GMPq::overload_mul_eq");
         }
       mpq_mul(*(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), t);
       mpq_clear(t);
       return a;
       }
#endif

     if(SvNOK(b)) {
       mpq_init(t);
#ifdef USE_LONG_DOUBLE
       _Rmpq_set_ld(aTHX_ &t, b);
#else
       mpq_set_d(t, SvNV(b));
#endif
       mpq_mul(*(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), t);
       mpq_clear(t);
       return a;
       }

     if(SvPOK(b)) {
       mpq_init(t);
       if(mpq_set_str(t, SvPV_nolen(b), 0)) {
         SvREFCNT_dec(a);
         croak("Invalid string supplied to Math::GMPq::overload_mul_eq");
         }
       mpq_canonicalize(t);
       mpq_mul(*(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), t);
       mpq_clear(t);
       return a;
       }

     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::GMPq")) {
         mpq_mul(*(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *(INT2PTR(mpq_t *, SvIV(SvRV(b)))));
         return a;
         }
       }

     SvREFCNT_dec(a);
     croak("Invalid argument supplied to Math::GMPq::overload_mul_eq");

}

SV * overload_add_eq(pTHX_ SV * a, SV * b, SV * third) {
     mpq_t t;

     SvREFCNT_inc(a);

#ifndef MATH_GMPQ_NEED_LONG_LONG_INT
     if(SvIOK(b)) {
       mpq_init(t);
       mpq_set_d(t, SvNV(b));
       mpq_add(*(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), t);
       mpq_clear(t);
       return a;
       }
#else
     if(SvIOK(b)) {
       mpq_init(t);
       if(mpq_set_str(t, SvPV_nolen(b), 0)) {
         SvREFCNT_dec(a);
         croak("Invalid string supplied to Math::GMPq::overload_add_eq");
         }
       mpq_add(*(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), t);
       mpq_clear(t);
       return a;
       }
#endif

     if(SvNOK(b)) {
       mpq_init(t);
#ifdef USE_LONG_DOUBLE
       _Rmpq_set_ld(aTHX_ &t, b);
#else
       mpq_set_d(t, SvNV(b));
#endif
       mpq_add(*(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), t);
       mpq_clear(t);
       return a;
       }

     if(SvPOK(b)) {
       mpq_init(t);
       if(mpq_set_str(t, SvPV_nolen(b), 0)) {
         SvREFCNT_dec(a);
         croak("Invalid string supplied to Math::GMPq::overload_add_eq");
         }
       mpq_canonicalize(t);
       mpq_add(*(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), t);
       mpq_clear(t);
       return a;
       }

     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::GMPq")) {
         mpq_add(*(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *(INT2PTR(mpq_t *, SvIV(SvRV(b)))));
         return a;
         }
       }

     SvREFCNT_dec(a);
     croak("Invalid argument supplied to Math::GMPq::overload_add_eq");
}

SV * overload_sub_eq(pTHX_ SV * a, SV * b, SV * third) {
     mpq_t t;

     SvREFCNT_inc(a);

#ifndef MATH_GMPQ_NEED_LONG_LONG_INT
     if(SvIOK(b)) {
       mpq_init(t);
       mpq_set_d(t, SvNV(b));
       mpq_sub(*(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), t);
       mpq_clear(t);
       return a;
       }
#else
     if(SvIOK(b)) {
       mpq_init(t);
       if(mpq_set_str(t, SvPV_nolen(b), 0)) {
         SvREFCNT_dec(a);
         croak("Invalid string supplied to Math::GMPq::overload_sub_eq");
         }
       mpq_sub(*(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), t);
       mpq_clear(t);
       return a;
       }
#endif

     if(SvNOK(b)) {
       mpq_init(t);
#ifdef USE_LONG_DOUBLE
       _Rmpq_set_ld(aTHX_ &t, b);
#else
       mpq_set_d(t, SvNV(b));
#endif
       mpq_sub(*(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), t);
       mpq_clear(t);
       return a;
       }

     if(SvPOK(b)) {
       mpq_init(t);
       if(mpq_set_str(t, SvPV_nolen(b), 0)) {
         SvREFCNT_dec(a);
         croak("Invalid string supplied to Math::GMPq::overload_sub_eq");
         }
       mpq_canonicalize(t);
       mpq_sub(*(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), t);
       mpq_clear(t);
       return a;
       }

     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::GMPq")) {
         mpq_sub(*(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *(INT2PTR(mpq_t *, SvIV(SvRV(b)))));
         return a;
         }
       }

     SvREFCNT_dec(a);
     croak("Invalid argument supplied to Math::GMPq::overload_sub_eq function");

}

SV * overload_div_eq(pTHX_ SV * a, SV * b, SV * third) {
     mpq_t t;

     SvREFCNT_inc(a);

#ifndef MATH_GMPQ_NEED_LONG_LONG_INT
     if(SvIOK(b)) {
       mpq_init(t);
       mpq_set_d(t, SvNV(b));
       mpq_div(*(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), t);
       mpq_clear(t);
       return a;
       }
#else
     if(SvIOK(b)) {
       mpq_init(t);
       if(mpq_set_str(t, SvPV_nolen(b), 0)) {
         SvREFCNT_dec(a);
         croak("Invalid string supplied to Math::GMPq::overload_div_eq");
         }
       mpq_div(*(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), t);
       mpq_clear(t);
       return a;
       }
#endif

     if(SvNOK(b)) {
       mpq_init(t);
#ifdef USE_LONG_DOUBLE
       _Rmpq_set_ld(aTHX_ &t, b);
#else
       mpq_set_d(t, SvNV(b));
#endif
       mpq_div(*(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), t);
       mpq_clear(t);
       return a;
       }

     if(SvPOK(b)) {
       mpq_init(t);
       if(mpq_set_str(t, SvPV_nolen(b), 0)) {
         SvREFCNT_dec(a);
         croak("Invalid string supplied to Math::GMPq::overload_div_eq");
         }
       mpq_canonicalize(t);
       mpq_div(*(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), t);
       mpq_clear(t);
       return a;
       }

     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::GMPq")) {
         mpq_div(*(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *(INT2PTR(mpq_t *, SvIV(SvRV(a)))), *(INT2PTR(mpq_t *, SvIV(SvRV(b)))));
         return a;
         }
       }

     SvREFCNT_dec(a);
     croak("Invalid argument supplied to Math::GMPq::overload_div_eq function");

}

SV * gmp_v(pTHX) {
#if __GNU_MP_VERSION >= 4
     return newSVpv(gmp_version, 0);
#else
     warn("From Math::GMPq::gmp_v(aTHX): 'gmp_version' is not implemented - returning '0'");
     return newSVpv("0", 0);
#endif
}

SV * wrap_gmp_printf(pTHX_ SV * a, SV * b) {
     int ret;
     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::GMPz") ||
         strEQ(h, "Math::GMP") ||
         strEQ(h, "GMP::Mpz")) {
         ret = gmp_printf(SvPV_nolen(a), *(INT2PTR(mpz_t *, SvIV(SvRV(b)))));
         fflush(stdout);
         return newSViv(ret);
       }
       if(strEQ(h, "Math::GMPq") ||
         strEQ(h, "GMP::Mpq")) {
         ret = gmp_printf(SvPV_nolen(a), *(INT2PTR(mpq_t *, SvIV(SvRV(b)))));
         fflush(stdout);
         return newSViv(ret);
       }
       if(strEQ(h, "Math::GMPf") ||
         strEQ(h, "GMP::Mpf")) {
         ret = gmp_printf(SvPV_nolen(a), *(INT2PTR(mpf_t *, SvIV(SvRV(b)))));
         fflush(stdout);
         return newSViv(ret);
       }

       croak("Unrecognised object supplied as argument to Rmpq_printf");
     }

     if(SvUOK(b)) {
       ret = gmp_printf(SvPV_nolen(a), SvUV(b));
       fflush(stdout);
       return newSViv(ret);
     }
     if(SvIOK(b)) {
       ret = gmp_printf(SvPV_nolen(a), SvIV(b));
       fflush(stdout);
       return newSViv(ret);
     }
     if(SvNOK(b)) {
       ret = gmp_printf(SvPV_nolen(a), SvNV(b));
       fflush(stdout);
       return newSViv(ret);
     }
     if(SvPOK(b)) {
       ret = gmp_printf(SvPV_nolen(a), SvPV_nolen(b));
       fflush(stdout);
       return newSViv(ret);
     }

     croak("Unrecognised type supplied as argument to Rmpq_printf");
}

SV * wrap_gmp_fprintf(pTHX_ FILE * stream, SV * a, SV * b) {
     int ret;
     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::GMPz") ||
         strEQ(h, "Math::GMP") ||
         strEQ(h, "GMP::Mpz")) {
         ret = gmp_fprintf(stream, SvPV_nolen(a), *(INT2PTR(mpz_t *, SvIV(SvRV(b)))));
         fflush(stream);
         return newSViv(ret);
       }
       if(strEQ(h, "Math::GMPq") ||
         strEQ(h, "GMP::Mpq")) {
         ret = gmp_fprintf(stream, SvPV_nolen(a), *(INT2PTR(mpq_t *, SvIV(SvRV(b)))));
         fflush(stream);
         return newSViv(ret);
       }
       if(strEQ(h, "Math::GMPf") ||
         strEQ(h, "GMP::Mpf")) {
         ret = gmp_fprintf(stream, SvPV_nolen(a), *(INT2PTR(mpf_t *, SvIV(SvRV(b)))));
         fflush(stream);
         return newSViv(ret);
       }

       else croak("Unrecognised object supplied as argument to Rmpq_fprintf");
     }

     if(SvUOK(b)) {
       ret = gmp_fprintf(stream, SvPV_nolen(a), SvUV(b));
       fflush(stream);
       return newSViv(ret);
     }
     if(SvIOK(b)) {
       ret = gmp_fprintf(stream, SvPV_nolen(a), SvIV(b));
       fflush(stream);
       return newSViv(ret);
     }
     if(SvNOK(b)) {
       ret = gmp_fprintf(stream, SvPV_nolen(a), SvNV(b));
       fflush(stream);
       return newSViv(ret);
     }
     if(SvPOK(b)) {
       ret = gmp_fprintf(stream, SvPV_nolen(a), SvPV_nolen(b));
       fflush(stream);
       return newSViv(ret);
     }

     croak("Unrecognised type supplied as argument to Rmpq_fprintf");
}

SV * wrap_gmp_sprintf(pTHX_ SV * s, SV * a, SV * b, int buflen) {
     int ret;
     char * stream;

     Newx(stream, buflen, char);

     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::GMPz") ||
         strEQ(h, "Math::GMP") ||
         strEQ(h, "GMP::Mpz")) {
         ret = gmp_sprintf(stream, SvPV_nolen(a), *(INT2PTR(mpz_t *, SvIV(SvRV(b)))));
         sv_setpv(s, stream);
         Safefree(stream);
         return newSViv(ret);
       }

       if(strEQ(h, "Math::GMPq") ||
         strEQ(h, "GMP::Mpq")) {
         ret = gmp_sprintf(stream, SvPV_nolen(a), *(INT2PTR(mpq_t *, SvIV(SvRV(b)))));
         sv_setpv(s, stream);
         Safefree(stream);
         return newSViv(ret);
       }

       if(strEQ(h, "Math::GMPf") ||
         strEQ(h, "GMP::Mpf")) {
         ret = gmp_sprintf(stream, SvPV_nolen(a), *(INT2PTR(mpf_t *, SvIV(SvRV(b)))));
         sv_setpv(s, stream);
         Safefree(stream);
         return newSViv(ret);
       }

       croak("Unrecognised object supplied as argument to Rmpq_sprintf");
     }

     if(SvUOK(b)) {
       ret = gmp_sprintf(stream, SvPV_nolen(a), SvUV(b));
       sv_setpv(s, stream);
       Safefree(stream);
       return newSViv(ret);
     }

     if(SvIOK(b)) {
       ret = gmp_sprintf(stream, SvPV_nolen(a), SvIV(b));
       sv_setpv(s, stream);
       Safefree(stream);
       return newSViv(ret);
     }

     if(SvNOK(b)) {
       ret = gmp_sprintf(stream, SvPV_nolen(a), SvNV(b));
       sv_setpv(s, stream);
       Safefree(stream);
       return newSViv(ret);
     }

     if(SvPOK(b)) {
       ret = gmp_sprintf(stream, SvPV_nolen(a), SvPV_nolen(b));
       sv_setpv(s, stream);
       Safefree(stream);
       return newSViv(ret);
     }

     croak("Unrecognised type supplied as argument to Rmpq_sprintf");
}

SV * wrap_gmp_snprintf(pTHX_ SV * s, SV * bytes, SV * a, SV * b, int buflen) {
     int ret;
     char * stream;

     Newx(stream, buflen, char);

     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::GMPz") ||
         strEQ(h, "Math::GMP") ||
         strEQ(h, "GMP::Mpz")) {
         ret = gmp_snprintf(stream, (size_t)SvUV(bytes), SvPV_nolen(a), *(INT2PTR(mpz_t *, SvIV(SvRV(b)))));
         sv_setpv(s, stream);
         Safefree(stream);
         return newSViv(ret);
       }

       if(strEQ(h, "Math::GMPq") ||
         strEQ(h, "GMP::Mpq")) {
         ret = gmp_snprintf(stream, (size_t)SvUV(bytes), SvPV_nolen(a), *(INT2PTR(mpq_t *, SvIV(SvRV(b)))));
         sv_setpv(s, stream);
         Safefree(stream);
         return newSViv(ret);
       }

       if(strEQ(h, "Math::GMPf") ||
         strEQ(h, "GMP::Mpf")) {
         ret = gmp_snprintf(stream, (size_t)SvUV(bytes), SvPV_nolen(a), *(INT2PTR(mpf_t *, SvIV(SvRV(b)))));
         sv_setpv(s, stream);
         Safefree(stream);
         return newSViv(ret);
       }

       croak("Unrecognised object supplied as argument to Rmpq_snprintf");
     }

     if(SvUOK(b)) {
       ret = gmp_snprintf(stream, (size_t)SvUV(bytes), SvPV_nolen(a), SvUV(b));
       sv_setpv(s, stream);
       Safefree(stream);
       return newSViv(ret);
     }

     if(SvIOK(b)) {
       ret = gmp_snprintf(stream, (size_t)SvUV(bytes), SvPV_nolen(a), SvIV(b));
       sv_setpv(s, stream);
       Safefree(stream);
       return newSViv(ret);
     }

     if(SvNOK(b)) {
       ret = gmp_snprintf(stream, (size_t)SvUV(bytes), SvPV_nolen(a), SvNV(b));
       sv_setpv(s, stream);
       Safefree(stream);
       return newSViv(ret);
     }

     if(SvPOK(b)) {
       ret = gmp_snprintf(stream, (size_t)SvUV(bytes), SvPV_nolen(a), SvPV_nolen(b));
       sv_setpv(s, stream);
       Safefree(stream);
       return newSViv(ret);
     }

     croak("Unrecognised type supplied as argument to Rmpq_snprintf");
}

int _itsa(pTHX_ SV * a) {
     if(SvUOK(a)) return 1;
     if(SvIOK(a)) return 2;
     if(SvNOK(a)) return 3;
     if(SvPOK(a)) return 4;
     if(sv_isobject(a)) {
       const char *h = HvNAME(SvSTASH(SvRV(a)));
       if(strEQ(h, "Math::GMPq")) return 7;
       }
     return 0;
}

int _has_longlong(void) {
#ifdef MATH_GMPQ_NEED_LONG_LONG_INT
    return 1;
#else
    return 0;
#endif
}

int _has_longdouble(void) {
#ifdef USE_LONG_DOUBLE
    return 1;
#else
    return 0;
#endif
}

/* Has inttypes.h been included ? */
int _has_inttypes(void) {
#ifdef _MSC_VER
return 0;
#else
#if defined MATH_GMPQ_NEED_LONG_LONG_INT
return 1;
#else
return 0;
#endif
#endif
}

SV * ___GNU_MP_VERSION(pTHX) {
     return newSVuv(__GNU_MP_VERSION);
}

SV * ___GNU_MP_VERSION_MINOR(pTHX) {
     return newSVuv(__GNU_MP_VERSION_MINOR);
}

SV * ___GNU_MP_VERSION_PATCHLEVEL(pTHX) {
     return newSVuv(__GNU_MP_VERSION_PATCHLEVEL);
}

SV * ___GNU_MP_RELEASE(pTHX) {
#if defined(__GNU_MP_RELEASE)
     return newSVuv(__GNU_MP_RELEASE);
#else
     return &PL_sv_undef;
#endif
}

SV * ___GMP_CC(pTHX) {
#ifdef __GMP_CC
     char * ret = __GMP_CC;
     return newSVpv(ret, 0);
#else
     return &PL_sv_undef;
#endif
}

SV * ___GMP_CFLAGS(pTHX) {
#ifdef __GMP_CFLAGS
     char * ret = __GMP_CFLAGS;
     return newSVpv(ret, 0);
#else
     return &PL_sv_undef;
#endif
}

SV * overload_inc(pTHX_ SV * p, SV * second, SV * third) {
     mpq_t one;

     mpq_init(one);
     mpq_set_ui(one, 1, 1);

     SvREFCNT_inc(p);
     mpq_add(*(INT2PTR(mpq_t *, SvIV(SvRV(p)))), *(INT2PTR(mpq_t *, SvIV(SvRV(p)))), one);
     mpq_clear(one);
     return p;
}

SV * overload_dec(pTHX_ SV * p, SV * second, SV * third) {
     mpq_t one;

     mpq_init(one);
     mpq_set_ui(one, 1, 1);

     SvREFCNT_inc(p);
     mpq_sub(*(INT2PTR(mpq_t *, SvIV(SvRV(p)))), *(INT2PTR(mpq_t *, SvIV(SvRV(p)))), one);
     mpq_clear(one);
     return p;
}

SV * _wrap_count(pTHX) {
     return newSVuv(PL_sv_count);
}

SV * overload_pow(pTHX_ SV * p, SV * second, SV * third) {
     if(sv_isobject(second)) {
       const char *h = HvNAME(SvSTASH(SvRV(second)));
       if(strEQ(h, "Math::MPFR")) {
         dSP;
         SV * ret;
         int count;

         ENTER;

         PUSHMARK(SP);
         XPUSHs(second);
         XPUSHs(p);
         XPUSHs(sv_2mortal(&PL_sv_yes));
         PUTBACK;

         count = call_pv("Math::MPFR::overload_pow", G_SCALAR);

         SPAGAIN;

         if (count != 1)
           croak("Error in Math::GMPq:overload_pow callback to Math::MPFR::overload_pow\n");

         ret = POPs;

         /* Avoid "Attempt to free unreferenced scalar" warning */
         SvREFCNT_inc(ret);
         LEAVE;
         return ret;
       }
     }

     croak("Invalid argument supplied to Math::GMPq::overload_pow. The function currently takes only a Math::MPFR object as the exponent - and returns a Math::MPFR object.");
}

SV * _get_xs_version(pTHX) {
     return newSVpv(XS_VERSION, 0);
}

int Rmpq_integer_p(mpq_t * q) {
    if(mpz_cmp_si(mpq_denref(*q), 1)) return 0;
    return 1;
}

SV * _GMP_LIMB_BITS(pTHX) {
#ifdef GMP_LIMB_BITS
     return newSVuv(GMP_LIMB_BITS);
#else
     return &PL_sv_undef;
#endif
}

SV * _GMP_NAIL_BITS(pTHX) {
#ifdef GMP_NAIL_BITS
     return newSVuv(GMP_NAIL_BITS);
#else
     return &PL_sv_undef;
#endif
}



MODULE = Math::GMPq  PACKAGE = Math::GMPq

PROTOTYPES: DISABLE


void
Rmpq_canonicalize (p)
	mpq_t *	p
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpq_canonicalize(p);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

SV *
Rmpq_init ()
CODE:
  RETVAL = Rmpq_init (aTHX);
OUTPUT:  RETVAL


SV *
Rmpq_init_nobless ()
CODE:
  RETVAL = Rmpq_init_nobless (aTHX);
OUTPUT:  RETVAL


void
DESTROY (p)
	mpq_t *	p
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        DESTROY(aTHX_ p);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpq_clear (p)
	mpq_t *	p
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpq_clear(aTHX_ p);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpq_clear_mpq (p)
	mpq_t *	p
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpq_clear_mpq(p);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpq_clear_ptr (p)
	mpq_t *	p
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpq_clear_ptr(aTHX_ p);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpq_set (p1, p2)
	mpq_t *	p1
	mpq_t *	p2
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpq_set(p1, p2);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpq_swap (p1, p2)
	mpq_t *	p1
	mpq_t *	p2
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpq_swap(p1, p2);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpq_set_z (p1, p2)
	mpq_t *	p1
	mpz_t *	p2
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpq_set_z(p1, p2);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpq_set_ui (p1, p2, p3)
	mpq_t *	p1
	unsigned long	p2
	unsigned long	p3
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpq_set_ui(p1, p2, p3);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpq_set_si (p1, p2, p3)
	mpq_t *	p1
	int	p2
	int	p3
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpq_set_si(p1, p2, p3);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpq_set_str (p1, p2, base)
	mpq_t *	p1
	SV *	p2
	SV *	base
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpq_set_str(aTHX_ p1, p2, base);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

double
Rmpq_get_d (p)
	mpq_t *	p

void
Rmpq_set_d (p, d)
	mpq_t *	p
	double	d
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpq_set_d(p, d);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
_Rmpq_set_ld (q, p)
	mpq_t *	q
	SV *	p
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        _Rmpq_set_ld(aTHX_ q, p);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpq_set_f (p, f)
	mpq_t *	p
	mpf_t *	f
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpq_set_f(p, f);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

SV *
Rmpq_get_str (p, base)
	mpq_t *	p
	SV *	base
CODE:
  RETVAL = Rmpq_get_str (aTHX_ p, base);
OUTPUT:  RETVAL

int
Rmpq_cmp (p1, p2)
	mpq_t *	p1
	mpq_t *	p2

int
Rmpq_cmp_ui (p1, n, d)
	mpq_t *	p1
	unsigned long	n
	unsigned long	d

int
Rmpq_cmp_si (p1, n, d)
	mpq_t *	p1
	long	n
	unsigned long	d

int
Rmpq_cmp_z (p, z)
	mpq_t *	p
	mpz_t *	z

int
Rmpq_sgn (p)
	mpq_t *	p

int
Rmpq_equal (p1, p2)
	mpq_t *	p1
	mpq_t *	p2

void
Rmpq_add (p1, p2, p3)
	mpq_t *	p1
	mpq_t *	p2
	mpq_t *	p3
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpq_add(p1, p2, p3);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpq_sub (p1, p2, p3)
	mpq_t *	p1
	mpq_t *	p2
	mpq_t *	p3
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpq_sub(p1, p2, p3);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpq_mul (p1, p2, p3)
	mpq_t *	p1
	mpq_t *	p2
	mpq_t *	p3
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpq_mul(p1, p2, p3);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpq_div (p1, p2, p3)
	mpq_t *	p1
	mpq_t *	p2
	mpq_t *	p3
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpq_div(p1, p2, p3);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpq_mul_2exp (p1, p2, p3)
	mpq_t *	p1
	mpq_t *	p2
	SV *	p3
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpq_mul_2exp(aTHX_ p1, p2, p3);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpq_div_2exp (p1, p2, p3)
	mpq_t *	p1
	mpq_t *	p2
	SV *	p3
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpq_div_2exp(aTHX_ p1, p2, p3);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpq_neg (p1, p2)
	mpq_t *	p1
	mpq_t *	p2
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpq_neg(p1, p2);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpq_abs (p1, p2)
	mpq_t *	p1
	mpq_t *	p2
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpq_abs(p1, p2);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpq_inv (p1, p2)
	mpq_t *	p1
	mpq_t *	p2
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpq_inv(p1, p2);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

SV *
_Rmpq_out_str (p, base)
	mpq_t *	p
	int	base
CODE:
  RETVAL = _Rmpq_out_str (aTHX_ p, base);
OUTPUT:  RETVAL

SV *
_Rmpq_out_strS (p, base, suff)
	mpq_t *	p
	int	base
	SV *	suff
CODE:
  RETVAL = _Rmpq_out_strS (aTHX_ p, base, suff);
OUTPUT:  RETVAL

SV *
_Rmpq_out_strP (pre, p, base)
	SV *	pre
	mpq_t *	p
	int	base
CODE:
  RETVAL = _Rmpq_out_strP (aTHX_ pre, p, base);
OUTPUT:  RETVAL

SV *
_Rmpq_out_strPS (pre, p, base, suff)
	SV *	pre
	mpq_t *	p
	int	base
	SV *	suff
CODE:
  RETVAL = _Rmpq_out_strPS (aTHX_ pre, p, base, suff);
OUTPUT:  RETVAL

SV *
_TRmpq_out_str (stream, base, p)
	FILE *	stream
	int	base
	mpq_t *	p
CODE:
  RETVAL = _TRmpq_out_str (aTHX_ stream, base, p);
OUTPUT:  RETVAL

SV *
_TRmpq_out_strS (stream, base, p, suff)
	FILE *	stream
	int	base
	mpq_t *	p
	SV *	suff
CODE:
  RETVAL = _TRmpq_out_strS (aTHX_ stream, base, p, suff);
OUTPUT:  RETVAL

SV *
_TRmpq_out_strP (pre, stream, base, p)
	SV *	pre
	FILE *	stream
	int	base
	mpq_t *	p
CODE:
  RETVAL = _TRmpq_out_strP (aTHX_ pre, stream, base, p);
OUTPUT:  RETVAL

SV *
_TRmpq_out_strPS (pre, stream, base, p, suff)
	SV *	pre
	FILE *	stream
	int	base
	mpq_t *	p
	SV *	suff
CODE:
  RETVAL = _TRmpq_out_strPS (aTHX_ pre, stream, base, p, suff);
OUTPUT:  RETVAL

SV *
TRmpq_inp_str (p, stream, base)
	mpq_t *	p
	FILE *	stream
	SV *	base
CODE:
  RETVAL = TRmpq_inp_str (aTHX_ p, stream, base);
OUTPUT:  RETVAL

SV *
Rmpq_inp_str (p, base)
	mpq_t *	p
	int	base
CODE:
  RETVAL = Rmpq_inp_str (aTHX_ p, base);
OUTPUT:  RETVAL

void
Rmpq_numref (z, r)
	mpz_t *	z
	mpq_t *	r
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpq_numref(z, r);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpq_denref (z, r)
	mpz_t *	z
	mpq_t *	r
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpq_denref(z, r);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpq_get_num (z, r)
	mpz_t *	z
	mpq_t *	r
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpq_get_num(z, r);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpq_get_den (z, r)
	mpz_t *	z
	mpq_t *	r
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpq_get_den(z, r);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpq_set_num (r, z)
	mpq_t *	r
	mpz_t *	z
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpq_set_num(r, z);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpq_set_den (r, z)
	mpq_t *	r
	mpz_t *	z
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpq_set_den(r, z);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

SV *
get_refcnt (s)
	SV *	s
CODE:
  RETVAL = get_refcnt (aTHX_ s);
OUTPUT:  RETVAL

SV *
overload_mul (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_mul (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_add (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_add (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_sub (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_sub (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_div (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_div (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_string (p, second, third)
	mpq_t *	p
	SV *	second
	SV *	third
CODE:
  RETVAL = overload_string (aTHX_ p, second, third);
OUTPUT:  RETVAL

SV *
overload_copy (p, second, third)
	mpq_t *	p
	SV *	second
	SV *	third
CODE:
  RETVAL = overload_copy (aTHX_ p, second, third);
OUTPUT:  RETVAL

SV *
overload_abs (p, second, third)
	mpq_t *	p
	SV *	second
	SV *	third
CODE:
  RETVAL = overload_abs (aTHX_ p, second, third);
OUTPUT:  RETVAL

SV *
overload_gt (a, b, third)
	mpq_t *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_gt (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_gte (a, b, third)
	mpq_t *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_gte (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_lt (a, b, third)
	mpq_t *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_lt (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_lte (a, b, third)
	mpq_t *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_lte (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_spaceship (a, b, third)
	mpq_t *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_spaceship (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_equiv (a, b, third)
	mpq_t *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_equiv (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_not_equiv (a, b, third)
	mpq_t *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_not_equiv (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_not (a, second, third)
	mpq_t *	a
	SV *	second
	SV *	third
CODE:
  RETVAL = overload_not (aTHX_ a, second, third);
OUTPUT:  RETVAL

SV *
overload_int (p, second, third)
	mpq_t *	p
	SV *	second
	SV *	third
CODE:
  RETVAL = overload_int (aTHX_ p, second, third);
OUTPUT:  RETVAL

SV *
overload_mul_eq (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_mul_eq (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_add_eq (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_add_eq (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_sub_eq (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_sub_eq (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_div_eq (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_div_eq (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
gmp_v ()
CODE:
  RETVAL = gmp_v (aTHX);
OUTPUT:  RETVAL


SV *
wrap_gmp_printf (a, b)
	SV *	a
	SV *	b
CODE:
  RETVAL = wrap_gmp_printf (aTHX_ a, b);
OUTPUT:  RETVAL

SV *
wrap_gmp_fprintf (stream, a, b)
	FILE *	stream
	SV *	a
	SV *	b
CODE:
  RETVAL = wrap_gmp_fprintf (aTHX_ stream, a, b);
OUTPUT:  RETVAL

SV *
wrap_gmp_sprintf (s, a, b, buflen)
	SV *	s
	SV *	a
	SV *	b
	int	buflen
CODE:
  RETVAL = wrap_gmp_sprintf (aTHX_ s, a, b, buflen);
OUTPUT:  RETVAL

SV *
wrap_gmp_snprintf (s, bytes, a, b, buflen)
	SV *	s
	SV *	bytes
	SV *	a
	SV *	b
	int	buflen
CODE:
  RETVAL = wrap_gmp_snprintf (aTHX_ s, bytes, a, b, buflen);
OUTPUT:  RETVAL

int
_itsa (a)
	SV *	a
CODE:
  RETVAL = _itsa (aTHX_ a);
OUTPUT:  RETVAL

int
_has_longlong ()


int
_has_longdouble ()


int
_has_inttypes ()


SV *
___GNU_MP_VERSION ()
CODE:
  RETVAL = ___GNU_MP_VERSION (aTHX);
OUTPUT:  RETVAL


SV *
___GNU_MP_VERSION_MINOR ()
CODE:
  RETVAL = ___GNU_MP_VERSION_MINOR (aTHX);
OUTPUT:  RETVAL


SV *
___GNU_MP_VERSION_PATCHLEVEL ()
CODE:
  RETVAL = ___GNU_MP_VERSION_PATCHLEVEL (aTHX);
OUTPUT:  RETVAL


SV *
___GNU_MP_RELEASE ()
CODE:
  RETVAL = ___GNU_MP_RELEASE (aTHX);
OUTPUT:  RETVAL


SV *
___GMP_CC ()
CODE:
  RETVAL = ___GMP_CC (aTHX);
OUTPUT:  RETVAL


SV *
___GMP_CFLAGS ()
CODE:
  RETVAL = ___GMP_CFLAGS (aTHX);
OUTPUT:  RETVAL


SV *
overload_inc (p, second, third)
	SV *	p
	SV *	second
	SV *	third
CODE:
  RETVAL = overload_inc (aTHX_ p, second, third);
OUTPUT:  RETVAL

SV *
overload_dec (p, second, third)
	SV *	p
	SV *	second
	SV *	third
CODE:
  RETVAL = overload_dec (aTHX_ p, second, third);
OUTPUT:  RETVAL

SV *
_wrap_count ()
CODE:
  RETVAL = _wrap_count (aTHX);
OUTPUT:  RETVAL


SV *
overload_pow (p, second, third)
	SV *	p
	SV *	second
	SV *	third
CODE:
  RETVAL = overload_pow (aTHX_ p, second, third);
OUTPUT:  RETVAL

SV *
_get_xs_version ()
CODE:
  RETVAL = _get_xs_version (aTHX);
OUTPUT:  RETVAL


int
Rmpq_integer_p (q)
	mpq_t *	q

SV *
_GMP_LIMB_BITS ()
CODE:
  RETVAL = _GMP_LIMB_BITS (aTHX);
OUTPUT:  RETVAL


SV *
_GMP_NAIL_BITS ()
CODE:
  RETVAL = _GMP_NAIL_BITS (aTHX);
OUTPUT:  RETVAL


