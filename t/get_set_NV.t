use strict;
use warnings;
use Math::GMPq qw(:mpq);
use Config;

use Test::More;

my $q = Rmpq_init();

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

  Rmpq_set_NV($q, $nv);
  my $nv_check = Rmpq_get_NV($q);

  cmp_ok($nv_check, '==', $nv, "2 ** $_ survives \"set and get\" round trip");
}

for (-1022, -1040, -16382, -16400, -1074, -16445, -16494) {
  my $pow = $_ + 20;
  my $nv = (2 ** $_);
  $nv += (2 ** $pow);

  Rmpq_set_NV($q, $nv);
  my $nv_check = Rmpq_get_NV($q);

  cmp_ok($nv_check, '==', $nv, "(2 ** $_) + (2 ** $pow) survives \"set and get\" round trip");
}

my $nv;

if($Config{nvsize} == 8)               { $nv = 1.7976931348623157e+308                    }
elsif($Config{nvtype} eq '__float128') { $nv = 1.18973149535723176508575932662800702e4932 }
else                                   { $nv = 1.18973149535723176502e4932                }

Rmpq_set_NV($q, $nv);
my $nv_check = Rmpq_get_NV($q);

cmp_ok($nv_check, '==', $nv, "NV_MAX survives \"set and get\" round trip");

done_testing();
