
use strict;
use warnings;
use Math::GMPq;
use Math::GMPz;

print "1..10\n";

my $q = Math::GMPq->new('-1/5');
my $z = Math::GMPq->new(8);

my $rop = $q + $z;

if($rop == '39/5') {print "ok 1\n"}
else {
  warn "\n Expected 39/5, got $rop\n";
  print "not ok 1\n";
}

$rop += $z;

if($rop == '79/5') {print "ok 2\n"}
else {
  warn "\n Expected 79/5, got $rop\n";
  print "not ok 2\n";
}

$rop -= $z;

if($rop == '39/5') {print "ok 3\n"}
else {
  warn "\n Expected 39/5, got $rop\n";
  print "not ok 3\n";
}

$rop = $rop * $z;

if($rop == '312/5') {print "ok 4\n"}
else {
  warn "\n Expected 312/5, got $rop\n";
  print "not ok 4\n";
}

$rop *= $z;

if($rop == '2496/5') {print "ok 5\n"}
else {
  warn "\n Expected 2496/5, got $rop\n";
  print "not ok 4\n";
}

$rop /= $z;

if($rop == '312/5') {print "ok 6\n"}
else {
  warn "\n Expected 312/5, got $rop\n";
  print "not ok 6\n";
}

$rop = $rop / $z;

if($rop == '39/5') {print "ok 7\n"}
else {
  warn "\n Expected 39/5, got $rop\n";
  print "not ok 7\n";
}

$rop = $rop - $z;

if($rop == '-1/5') {print "ok 8\n"}
else {
  warn "\n Expected -1/5, got $rop\n";
  print "not ok 8\n";
}

$rop = $rop ** 3;

if($rop == '-1/125') {print "ok 9\n"}
else {
  warn "\n Expected -1/125, got $rop\n";
  print "not ok 9\n";
}

$rop **= 2;

if($rop == '1/15625') {print "ok 10\n"}
else {
  warn "\n Expected 1/15625, got $rop\n";
  print "not ok 10\n";
}
