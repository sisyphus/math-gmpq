# Test cross class overloading of +=, *=, -=, /=, and
# and **= for the cases where the second arg is a
# Math::MPFR object.
# In these cases the operation returns a Math::MPFR
# object if and only if $Math::GMPq::RETYPE is set
# to a true value.
# A fatal error occurs if $Math::GMPq::RETYPE is
# set to a false value. The initial value of
# $Math::GMPq::RETYPE is 0 (false).

use strict;
use warnings;
use Math::GMPq qw(:mpq);

use Test::More;

my $have_mpfr = 0;
eval {require Math::MPFR;};
$have_mpfr = 1 unless $@;

my $q  = Math::GMPq->new('1/11');
my $fr = 0;
$fr = Math::MPFR->new(17.1) if $have_mpfr;

# $Math::GMPz::RETYPE 0 (the default).

eval {$q *= $fr;};
like($@, qr/^Invalid argument supplied to Math::GMPq::overload_mul_eq/, '$q *= $q is illegal');

eval {$q += $fr;};
like($@, qr/^Invalid argument supplied to Math::GMPq::overload_add_eq/, '$q += $fr is illegal');

eval {$q -= $fr;};
like($@, qr/^Invalid argument supplied to Math::GMPq::overload_sub_eq/, '$q -= $fr is illegal');

eval {$q /= $fr;};
like($@, qr/^Invalid argument supplied to Math::GMPq::overload_div_eq/, '$q /= $fr is illegal');

eval {$q **= $fr;};
like($@, qr/^Invalid argument supplied to Math::GMPq::overload_pow_eq/, '$q **= $fr is illegal');

$Math::GMPq::RETYPE = 1;

############################################

if($have_mpfr) {

  $q = Math::GMPq->new('1/11');
  cmp_ok(ref($q), 'eq', 'Math::GMPq', '$q is a Math::GMPq object');
  $q *= $fr;
  cmp_ok(ref($q), 'eq', 'Math::MPFR', '$q changes to a Math::MPFR object');
  cmp_ok($q, '==', $fr * Math::GMPq->new('1/11'), '$q *= $fr sets $q to 1.5545454545454547');

  $q = Math::GMPq->new('1/11');
  cmp_ok(ref($q), 'eq', 'Math::GMPq', '$q has been reverted to a Math::GMPq object');
  $q += $fr;
  cmp_ok(ref($q), 'eq', 'Math::MPFR', '$q changes to a Math::MPFR object');
  cmp_ok($q, '==', $fr + Math::GMPq->new('1/11'), '$q += $fr sets $q to 1.7190909090909091e1');

  $q = Math::GMPq->new('1/11');
  $q -= $fr;
  cmp_ok(ref($q), 'eq', 'Math::MPFR', '$q changes to a Math::MPFR object');
  cmp_ok($q, '==', Math::GMPq->new('1/11') - $fr, '$q -= $fr sets $z to -1.7009090909090911e1');

  $q = Math::GMPq->new('1/11');
  $q /= $fr;
  cmp_ok(ref($q), 'eq', 'Math::MPFR', '$q changes to a Math::MPFR object');
  cmp_ok($q, '==', Math::GMPq->new('1/11') / $fr, '$q /= $fr sets $q to 5.3163211057947893e-3');

  $q = Math::GMPq->new(2);
  $q **= Math::MPFR->new(0.5);
  cmp_ok(ref($q), 'eq', 'Math::MPFR', '$q changes to a Math::MPFR object');
  cmp_ok($q, '==', Math::GMPq->new(2) ** Math::MPFR->new(0.5), '$q **= $Math::MPFR->new(0.5) sets $q to 1.4142135623730951');

  $q = Math::GMPq->new(2);
  Math::MPFR::Rmpfr_set_default_prec(113);
  $q **= Math::MPFR->new(0.5);
  cmp_ok(ref($q), 'eq', 'Math::MPFR', '$q changes to a Math::MPFR object');
  cmp_ok($q, '==', Math::GMPq->new(2) ** Math::MPFR->new(0.5), '$q **= Math::MPFR->new(0.5) sets $z to 1.41421356237309504880168872420969798');

}

done_testing();
