use warnings;
use strict;
use Math::GMPq qw(:mpq);
use Math::BigInt;
use Config;

print "1..8\n";

print "# Using gmp version ", Math::GMPq::gmp_v(), "\n";

my @version = split /\./, Math::GMPq::gmp_v();
my $old = 0;
if($version[0] == 4 && $version[1] < 2) {$old = 1}
if($old) {warn "Tests 1, 2 & 3 should fail - GMP version ", Math::GMPf::gmp_v(), " is old and doesn't support base 62\n";}

my $ui = 123569;
my $si = -19907;
my $d = -1.625;
my $str = '-119125/1000';

my $ok = '';

my $f000 = new Math::GMPq('z/1', 62);
if($f000 == 61) {$ok .= 'a'}

my $f00 = new Math::GMPq();
Rmpq_set_ui($f00, $ui, 1);
if($f00 == $ui) {$ok .= 'b'}

my $f01 = new Math::GMPq($ui);
if($f01 == $ui) {$ok .= 'c'}

my $f02 = new Math::GMPq($si);
if($f02 == $si) {$ok .= 'd'}

my $f03 = new Math::GMPq($d);
if($f03 == $d) {$ok .= 'e'}

my $f04 = new Math::GMPq($str);
if($f04 == $str) {$ok .= 'f'}

my $f05 = new Math::GMPq($str, 10);
if($f05 == $str) {$ok .= 'g'}

my $f06 = new Math::GMPq($d);
if($f06 == $d) {$ok .= 'h'}

if($ok eq 'abcdefgh') {print "ok 1\n"}
else {print "not ok 1 $ok\n"}

#############################


$ok = '';

my $f09 = Math::GMPq::new('z/1', 62);
if($f09 == 61) {$ok .= 'a'}

my $f10 = Math::GMPq::new();
Rmpq_set_ui($f10, $ui, 1);
if($f10 == $ui) {$ok .= 'b'}

my $f11 = Math::GMPq::new($ui);
if($f11 == $ui) {$ok .= 'c'}

my $f12 = Math::GMPq::new($si);
if($f12 == $si) {$ok .= 'd'}

my $f13 = Math::GMPq::new($d);
if($f13 == $d) {$ok .= 'e'}

my $f14 = Math::GMPq::new($str);
if($f14 == $str) {$ok .= 'f'}

my $f15 = Math::GMPq::new($str, 10);
if($f15 == $str) {$ok .= 'g'}

my $f16 = Math::GMPq::new($d);
if($f16 == $d) {$ok .= 'h'}

if($ok eq 'abcdefgh') {print "ok 2\n"}
else {print "not ok 2 $ok\n"}

################################

$ok = '';

my $f19 = Math::GMPq->new('z/1', 62);
if($f19 == 61) {$ok .= 'a'}
else{warn "3a: Expected 61\n    Got $f19\n"}

my $f20 = Math::GMPq->new();
Rmpq_set_ui($f20, $ui, 1);
if($f20 == $ui) {$ok .= 'b'}
else{warn "3b: Expected $ui\n    Got $f20\n"}

my $f21 = Math::GMPq->new($ui);
if($f21 == $ui) {$ok .= 'c'}
else{warn "3c: Expected $ui\n    Got $f21\n"}

my $f22 = Math::GMPq->new($si);
if($f22 == $si) {$ok .= 'd'}
else{warn "3d: Expected $si\n    Got $f22\n"}

my $f23 = Math::GMPq->new($d);
if($f23 == $d) {$ok .= 'e'}
else{warn "3e: Expected $d\n    Got $f23\n"}

my $f24 = Math::GMPq->new($str);
if($f24 == $str) {$ok .= 'f'}
else{warn "3f: Expected $str\n    Got $f24\n"}

my $f25 = Math::GMPq->new($str, 10);
if($f25 == $str) {$ok .= 'g'}
else{warn "3g: Expected $str\n    Got $f25\n"}

my $f26 = Math::GMPq->new($d);
if($f26 == $d) {$ok .= 'h'}
else{warn "3h: Expected $d\n    Got $f26\n"}

my $f27 = Math::GMPq->new(36028797018964023);
my $f28 = Math::GMPq->new('36028797018964023');

if($Config{ivsize} > 4 || $Config{nvsize} > 8) {
  if($f27 == $f28) {$ok .= 'i'}
  else{warn "3i: Should have $f27 == $f28\n"}
}
else {
  if($f27 != $f28) {$ok .= 'i'}
  else{warn "3i: Should have $f27 != $f28\n"}
}

if($ok eq 'abcdefghi') {print "ok 3\n"}
else {print "not ok 3 $ok\n"}

#############################

my $bi = Math::BigInt->new(123456789);

$ok = '';

eval{my $f30 = Math::GMPq->new(17, 12);};
if($@ =~ /Too many arguments supplied to new\(\) \- expected only one/) {$ok = 'a'}

eval{my $f31 = Math::GMPq::new(17, 12);};
if($@ =~ /Too many arguments supplied to new\(\) \- expected only one/) {$ok .= 'b'}

eval{my $f32 = Math::GMPq->new($str, 12, 7);};
if($@ =~ /Too many arguments supplied to new\(\)/) {$ok .= 'c'}

eval{my $f33 = Math::GMPq::new($str, 12, 7);};
if($@ =~ /Too many arguments supplied to new\(\) \- expected no more than two/) {$ok .= 'd'}

eval{my $f34 = Math::GMPq->new($bi);};
if($@ =~ /Inappropriate argument/) {$ok .= 'e'}

eval{my $f35 = Math::GMPq::new($bi);};
if($@ =~ /Inappropriate argument/) {$ok .= 'f'}

eval{my $f30 = Math::GMPq->new($f27, 12);};
if($@ =~ /Too many arguments supplied to new\(\) \- expected only one/) {$ok .= 'g'}

eval{my $f31 = Math::GMPq::new($f27, 12);};
if($@ =~ /Too many arguments supplied to new\(\) \- expected only one/) {$ok .= 'h'}

eval{my $f32 = Math::GMPq->new($str, -1);};
if($@ =~ /Invalid value for base/) {$ok .= 'i'}

if($ok eq 'abcdefghi') {print "ok 4\n"}
else {print "not ok 4 $ok\n"}

eval { require Math::MPFR;};
unless($@) {
  if($Math::MPFR::VERSION >= 4.15) {  # Test needs decimalize()
    my $fr = Math::MPFR::Rmpfr_init2(113);
    Math::MPFR::Rmpfr_set_str($fr, "1.3", 10, 0);
    Math::MPFR::Rmpfr_div_ui($fr, $fr, 10,  0);
    my $q1 = Math::GMPq->new($fr);
    my $q2 = Math::GMPq->new(Math::MPFR::decimalize($fr));

    if($q1 == $q2) { print "ok 5\n" }
    else {
      warn "$q1\n$q2\n";
      print "not ok 5\n";
    }
  }
  else {
    warn "Test 5 needs Math-MPFR-4.15 or later - we have only version $Math::MPFR::VERSION\n";
    print "ok 5\n";
  }
}
else {
  warn "Could not load Math::MPFR\n";
  print "ok 5\n";
}

eval { require Math::GMP;};
unless($@) {
  my $gmp = Math::GMP->new(12345678);
  my $q1 = Math::GMPq->new($gmp);
  my $q2 = Math::GMPq->new('12345678');

  if($q1 == $q2) { print "ok 6\n" }
  else {
    warn "$q1\n$q2\n";
    print "not ok 6\n";
  }
}
else {
  warn "Could not load Math::GMP";
  print "ok 6\n";
}

eval { require Math::GMPz;};
unless($@) {
  my $mpz = Math::GMPz->new(12345678);
  my $q1 = Math::GMPq->new($mpz);
  my $q2 = Math::GMPq->new('12345678');

  if($q1 == $q2) { print "ok 7\n" }
  else {
    warn "$q1\n$q2\n";
    print "not ok 7\n";
  }
}
else {
  warn "Could not load Math::GMPz";
  print "ok 7\n";
}

# Check that whitespace is ignored in new().
my $q1 = Math::GMPq->new('213/5');
my $q2 = Math::GMPq->new("21 \n  3 \t\n / 5");

if($q1 == $q2) { print "ok 8\n" }
else {
  warn "$q1\n$q2\n";
  print "not ok 8\n";
}

