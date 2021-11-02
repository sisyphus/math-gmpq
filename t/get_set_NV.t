use strict;
use warnings;
use Math::GMPq qw(:mpq IOK_flag NOK_flag POK_flag);
use Config;

use Test::More;

my $q = Rmpq_init();

my $set = 0.7830584899793429087822005385533 * 0.3837528960584712933723494643345;

for(1 .. 10) {

  my $nv = rand() / 1.01;
  $nv *= -1 if $_ % 2;

  Rmpq_set_NV($q, $nv);
  my $nv_check = Rmpq_get_NV($q);
  my $id = sprintf "%a", $nv;

  cmp_ok($nv_check, '==', $nv, "$id survives \"set and get\" round trip");
}

for (-1022, -1040, -16382, -16400 -1074, -16445, -16494) {
  my $nv = 2 ** $_;

  if(NOK_flag($nv)) {
     Rmpq_set_NV($q, $nv);
  }
  else {
     Rmpq_set_IV($q, $nv, 1);
  }

  my $nv_check = Rmpq_get_NV($q);

  cmp_ok($nv_check, '==', $nv, "2 ** $_ survives \"set and get\" round trip");
}

for (-1022, -1040, -16382, -16400, -1074, -16445, -16494) {
  my $pow = $_ + 20;
  my $nv = (2 ** $_);
  $nv += (2 ** $pow);

  if(NOK_flag($nv)) {
     Rmpq_set_NV($q, $nv);
  }
  else {
     Rmpq_set_IV($q, $nv, 1);
  }

  my $nv_check = Rmpq_get_NV($q);

  cmp_ok($nv_check, '==', $nv, "(2 ** $_) + (2 ** $pow) survives \"set and get\" round trip");
}

my $nv;

if($Config{nvsize} == 8
     ||
   ($Config{nvtype} eq 'long double'
       &&
    Math::GMPq::_required_ldbl_mant_dig() == 2098))
                                                 { $nv = 1.7976931348623157e+308                    }
elsif($Config{nvtype} eq '__float128')           { $nv = 1.18973149535723176508575932662800702e4932 }
else                                             { $nv = 1.18973149535723176502e4932                }

# $nv is NV_MAX and a buggy perls could assign that value
# as 'INf', so we avoid the next test if we hit such a bug.
eval {Rmpq_set_NV($q, $nv);};

my $nv_check;

if($@ && $@ =~ /cannot coerce an Inf to a Math::GMP/) {
  warn "\nThis perl incorrectly assigns NV_MAX as Inf\n";
}
else {
  $nv_check = Rmpq_get_NV($q);
  cmp_ok($nv_check, '==', $nv, "NV_MAX survives \"set and get\" round trip");
}

Rmpq_set_NV($q, $set);
$nv_check = Rmpq_get_NV($q);

cmp_ok($nv_check, '==', $set, "$set survives \"set and get\" round trip");

cmp_ok(POK_flag("$nv_check"), '==', 1, "POK_flag set as expected"  );
cmp_ok(POK_flag(2.5)        , '==', 0, "POK_flag unset as expected");

done_testing();
