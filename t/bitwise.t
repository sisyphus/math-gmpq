use strict;
use warnings;
use Math::GMPq qw(:mpq);
use Math::BigRat;

use Test::More;

for my $s1('11.234', '-1023.67', '89.911') {
  my $mpq1 = Math::GMPq->new($s1);
  my $mbr1 = Math::BigRat->new($s1);
  cmp_ok($mpq1, '==', "$mbr1", 'mpq == "mbr"');
  cmp_ok($mbr1, '==', "$mpq1", 'mbr == "mpq"');

  my $mpq_com = ~ $mpq1;
  my $mbr_com = ~ $mbr1;
  cmp_ok("$mpq_com", 'eq', $mbr_com, "~ $s1: GMPq and BigRat concur");

  for my $s2('0.009', '1165.1', '200000000.997', 0) {
    my $mpq2 = Math::GMPq->new($s2);
    my $mbr2 = Math::BigRat->new($s2);

    my $mpq_and = $mpq1 & $mpq2;
    my $mbr_and = $mbr1 & $mbr2;
    cmp_ok("$mpq_and", 'eq', $mbr_and, "$s1 & $s2: GMPq and BigRat concur");

    my $mpq_ior = $mpq1 | $mpq2;
    my $mbr_ior = $mbr1 | $mbr2;
    cmp_ok("$mpq_ior", 'eq', $mbr_ior, "$s1 | $s2: GMPq and BigRat concur");

    my $mpq_xor = $mpq1 ^ $mpq2;
    my $mbr_xor = $mbr1 ^ $mbr2;
    cmp_ok("$mpq_ior", 'eq', $mbr_ior, "$s1 ^ $s2: GMPq and BigRat concur");
  }
}

my $shift = '89.99';
my $mpq_ls = Math::GMPq->new  ($shift) << 4;
my $mbr_ls = Math::BigRat->new($shift) << 4;

cmp_ok("$mpq_ls", 'eq', "$mbr_ls", "$shift << 4: GMPq and BigRat concur");
cmp_ok("$mpq_ls", '==', Math::GMPq->new  ($shift) << 4.99, "GMPq: same result with left shift of 4.99");
cmp_ok("$mbr_ls", '==', Math::BigRat::->new  ($shift) << 4.99, "BigRat: same result with left shift of 4.99");

my $mpq_rs = Math::GMPq->new  ($shift) >> 2;
my $mbr_rs = Math::BigRat->new($shift) >> 2;
cmp_ok("$mpq_rs", 'eq', "$mbr_rs", "$shift >> 2: GMPq and BigRat concur");
cmp_ok("$mpq_rs", '==', Math::GMPq->new  ($shift) >> 2.99, "GMPq: same result with right shift of 2.99");
cmp_ok("$mbr_rs", '==', Math::BigRat::->new  ($shift) >> 2.99, "BigRat: same result with right shift of 2.99");

done_testing();


















