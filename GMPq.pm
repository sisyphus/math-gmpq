    package Math::GMPq;
    use strict;
    use Math::GMPq::Random;
    require Exporter;
    *import = \&Exporter::import;
    require DynaLoader;

    use constant _UOK_T         => 1;
    use constant _IOK_T         => 2;
    use constant _NOK_T         => 3;
    use constant _POK_T         => 4;
    use constant _MATH_MPFR_T   => 5;
    use constant _MATH_GMPf_T   => 6;
    use constant _MATH_GMPq_T   => 7;
    use constant _MATH_GMPz_T   => 8;
    use constant _MATH_GMP_T    => 9;
    use constant _MATH_MPC_T    => 10;

use subs qw( __GNU_MP_VERSION __GNU_MP_VERSION_MINOR __GNU_MP_VERSION_PATCHLEVEL
             __GNU_MP_RELEASE __GMP_CC __GMP_CFLAGS GMP_LIMB_BITS GMP_NAIL_BITS);

use overload
    '++'   => \&overload_inc,
    '--'   => \&overload_dec,
    '+'    => \&overload_add,
    '-'    => \&overload_sub,
    '*'    => \&overload_mul,
    '/'    => \&overload_div,
    '+='   => \&overload_add_eq,
    '-='   => \&overload_sub_eq,
    '*='   => \&overload_mul_eq,
    '/='   => \&overload_div_eq,
    '""'   => \&overload_string,
    '>'    => \&overload_gt,
    '>='   => \&overload_gte,
    '<'    => \&overload_lt,
    '<='   => \&overload_lte,
    '<=>'  => \&overload_spaceship,
    '=='   => \&overload_equiv,
    '!='   => \&overload_not_equiv,
    '!'    => \&overload_not,
    '='    => \&overload_copy,
    'int'  => \&overload_int,
    'abs'  => \&overload_abs;

    @Math::GMPq::EXPORT_OK = qw(
__GNU_MP_VERSION __GNU_MP_VERSION_MINOR __GNU_MP_VERSION_PATCHLEVEL
__GNU_MP_RELEASE __GMP_CC __GMP_CFLAGS
Rmpq_abs Rmpq_add Rmpq_canonicalize Rmpq_clear Rmpq_cmp Rmpq_cmp_si Rmpq_cmp_ui
Rmpq_cmp_z
Rmpq_create_noval Rmpq_denref Rmpq_div Rmpq_div_2exp Rmpq_equal
Rmpq_fprintf
Rmpq_get_d
Rmpq_get_den Rmpq_get_num Rmpq_get_str Rmpq_init Rmpq_init_nobless Rmpq_inp_str
Rmpq_inv Rmpq_mul Rmpq_mul_2exp Rmpq_neg Rmpq_numref Rmpq_out_str Rmpq_printf
Rmpq_set Rmpq_set_d Rmpq_set_den Rmpq_set_f Rmpq_set_num Rmpq_set_si Rmpq_set_str
Rmpq_set_ui Rmpq_set_z Rmpq_sgn
Rmpq_sprintf Rmpq_snprintf
Rmpq_sub Rmpq_swap
Rmpq_integer_p
TRmpq_out_str TRmpq_inp_str
qgmp_randseed qgmp_randseed_ui qgmp_randclear
qgmp_randinit_default qgmp_randinit_mt qgmp_randinit_lc_2exp qgmp_randinit_lc_2exp_size
qgmp_randinit_set qgmp_randinit_default_nobless qgmp_randinit_mt_nobless
qgmp_randinit_lc_2exp_nobless qgmp_randinit_lc_2exp_size_nobless qgmp_randinit_set_nobless
qgmp_urandomb_ui qgmp_urandomm_ui
    );
    our $VERSION = '0.42';
    #$VERSION = eval $VERSION;

    DynaLoader::bootstrap Math::GMPq $VERSION;

    %Math::GMPq::EXPORT_TAGS =(mpq => [qw(
Rmpq_abs Rmpq_add Rmpq_canonicalize Rmpq_clear Rmpq_cmp Rmpq_cmp_si Rmpq_cmp_ui
Rmpq_cmp_z
Rmpq_create_noval Rmpq_denref Rmpq_div Rmpq_div_2exp Rmpq_equal
Rmpq_fprintf
Rmpq_get_d
Rmpq_get_den Rmpq_get_num Rmpq_get_str Rmpq_init Rmpq_init_nobless Rmpq_inp_str
Rmpq_inv Rmpq_mul Rmpq_mul_2exp Rmpq_neg Rmpq_numref Rmpq_out_str Rmpq_printf
Rmpq_set Rmpq_set_d Rmpq_set_den Rmpq_set_f Rmpq_set_num Rmpq_set_si Rmpq_set_str
Rmpq_set_ui Rmpq_set_z Rmpq_sgn
Rmpq_sprintf Rmpq_snprintf
Rmpq_sub Rmpq_swap
Rmpq_integer_p
TRmpq_out_str TRmpq_inp_str
qgmp_randseed qgmp_randseed_ui qgmp_randclear
qgmp_randinit_default qgmp_randinit_mt qgmp_randinit_lc_2exp qgmp_randinit_lc_2exp_size
qgmp_randinit_set qgmp_randinit_default_nobless qgmp_randinit_mt_nobless
qgmp_randinit_lc_2exp_nobless qgmp_randinit_lc_2exp_size_nobless qgmp_randinit_set_nobless
qgmp_urandomb_ui qgmp_urandomm_ui
)]);

sub dl_load_flags {0} # Prevent DynaLoader from complaining and croaking

sub new {

    # This function caters for 2 possibilities:
    # 1) that 'new' has been called OOP style - in which
    #    case there will be a maximum of 3 args
    # 2) that 'new' has been called as a function - in
    #    which case there will be a maximum of 2 args.
    # If there are no args, then we just want to return an
    # initialized Math::GMPq
    if(!@_) {return Rmpq_init()}

    if(@_ > 3) {die "Too many arguments supplied to new()"}

    # If 'new' has been called OOP style, the first arg is the string
    # "Math::GMPq" which we don't need - so let's remove it. However,
    # if the first arg is a Math::GMPq object (which is a possibility),
    # then we'll get a fatal error when we check it for equivalence to
    # the string "Math::GMPq". So we first need to check that it's not
    # an object - which we'll do by using the ref() function:
    if(!ref($_[0]) && $_[0] eq "Math::GMPq") {
      shift;
      if(!@_) {return Rmpq_init()}
      }

    # @_ can now contain a maximum of 2 args - the value, and iff the value is
    # a string, (optionally) the base of the numeric string.
    if(@_ > 2) {die "Too many arguments supplied to new() - expected no more than two"}

    my ($arg1, $type, $base);

    # $_[0] is the value, $_[1] (if supplied) is the base of the number
    # in the string $[_0].
    $arg1 = shift;
    $base = 0;

    $type = _itsa($arg1);
    if(!$type) {die "Inappropriate argument supplied to new()"}

    my $ret = Rmpq_init();

    # Create a Math::GMPq object that has $arg1 as its value.
    # Die if there are any additional args (unless $type == _POK_T)
    if($type == _UOK_T || $type == _IOK_T) {
      if(@_ ) {die "Too many arguments supplied to new() - expected only one"}
      Rmpq_set_str($ret, $arg1, 10);
      return $ret;
    }

    if($type == _NOK_T) {
      if(@_ ) {die "Too many arguments supplied to new() - expected only one"}
      if(Math::GMPq::_has_longdouble()) {
        _Rmpq_set_ld($ret, $arg1);
        return $ret;
      }
      Rmpq_set_d($ret, $arg1);
      return $ret;
    }

    if($type == _POK_T) {
      if(@_ > 1) {die "Too many arguments supplied to new() - expected no more than two"}
      $base = shift if @_;
      if(($base < 2 && $base != 0) || $base > 62) {die "Invalid value for base"}
      Rmpq_set_str($ret, $arg1, $base);
      Rmpq_canonicalize($ret);
      return $ret;
    }

    if($type == _MATH_GMPq_T) { # Math::GMPq object
      if(@_) {die "Too many arguments supplied to new() - expected only one"}
      Rmpq_set($ret, $arg1);
      return $ret;
    }
}

sub Rmpq_out_str {
    if(@_ == 2) {
       die "Inappropriate 1st arg supplied to Rmpq_out_str" if _itsa($_[0]) != _MATH_GMPq_T;
       return _Rmpq_out_str($_[0], $_[1]);
    }
    if(@_ == 3) {
      if(_itsa($_[0]) == _MATH_GMPq_T) {return _Rmpq_out_strS($_[0], $_[1], $_[2])}
      die "Incorrect args supplied to Rmpq_out_str" if _itsa($_[1]) != _MATH_GMPq_T;
      return _Rmpq_out_strP($_[0], $_[1], $_[2]);
    }
    if(@_ == 4) {
      die "Inappropriate 2nd arg supplied to Rmpq_out_str" if _itsa($_[1]) != _MATH_GMPq_T;
      return _Rmpq_out_strPS($_[0], $_[1], $_[2], $_[3]);
    }
    die "Wrong number of arguments supplied to Rmpq_out_str()";
}

sub TRmpq_out_str {
    if(@_ == 3) {
      die "Inappropriate 3rd arg supplied to TRmpq_out_str" if _itsa($_[2]) != _MATH_GMPq_T;
      return _TRmpq_out_str($_[0], $_[1], $_[2]);
    }
    if(@_ == 4) {
      if(_itsa($_[2]) == _MATH_GMPq_T) {return _TRmpq_out_strS($_[0], $_[1], $_[2], $_[3])}
      die "Incorrect args supplied to TRmpq_out_str" if _itsa($_[3]) != _MATH_GMPq_T;
      return _TRmpq_out_strP($_[0], $_[1], $_[2], $_[3]);
    }
    if(@_ == 5) {
      die "Inappropriate 4th arg supplied to TRmpq_out_str" if _itsa($_[3]) != _MATH_GMPq_T;
      return _TRmpq_out_strPS($_[0], $_[1], $_[2], $_[3], $_[4]);
    }
    die "Wrong number of arguments supplied to TRmpq_out_str()";
}

sub _rewrite {
    my $len = length($_[0]);
    my @split = ();
    my @ret = ();
    for(my $i = 0; $i < $len - 1; $i++) {
       if(substr($_[0], $i, 1) eq '%') {
         if(substr($_[0], $i + 1, 1) eq '%') { $i++ }
         else { push(@split, $i) }
         }
       }

    push(@split, $len);
    shift(@split);

    my $start = 0;

    for(@split) {
       push(@ret, substr($_[0], $start, $_ - $start));
       $start = $_;
       }

    return @ret;
}

sub Rmpq_printf {
    local $| = 1;
    push @_, 0 if @_ == 1; # add a dummy second argument
    die "Rmpz_printf must pass 2 arguments: format string, and variable" if @_ != 2;
    wrap_gmp_printf(@_);
}

sub Rmpq_fprintf {
    push @_, 0 if @_ == 2; # add a dummy third argument
    die "Rmpq_fprintf must pass 3 arguments: filehandle, format string, and variable" if @_ != 3;
    wrap_gmp_fprintf(@_);
}

sub Rmpq_sprintf {
    my $len;

    if(@_ == 3) {      # optional arg wasn't provided
      $len = wrap_gmp_sprintf($_[0], $_[1], 0, $_[2]);  # Set missing arg to 0
    }
    else {
      die "Rmpq_sprintf must pass 4 arguments: buffer, format string, variable, buflen" if @_ != 4;
      $len = wrap_gmp_sprintf(@_);
    }

    return $len;
}

sub Rmpq_snprintf {
    my $len;

    if(@_ == 4) {      # optional arg wasn't provided
      $len = wrap_gmp_snprintf($_[0], $_[1], $_[2], 0, $_[3]);  # Set missing arg to 0
    }
    else {
      die "Rmpq_snprintf must pass 5 arguments: buffer, bytes written, format string, variable and buflen" if @_ != 5;
      $len = wrap_gmp_snprintf(@_);
    }

    return $len;
}

sub __GNU_MP_VERSION {return ___GNU_MP_VERSION()}
sub __GNU_MP_VERSION_MINOR {return ___GNU_MP_VERSION_MINOR()}
sub __GNU_MP_VERSION_PATCHLEVEL {return ___GNU_MP_VERSION_PATCHLEVEL()}
sub __GNU_MP_RELEASE {return ___GNU_MP_RELEASE()}
sub __GMP_CC {return ___GMP_CC()}
sub __GMP_CFLAGS {return ___GMP_CFLAGS()}
sub GMP_LIMB_BITS {return _GMP_LIMB_BITS()}
sub GMP_NAIL_BITS {return _GMP_NAIL_BITS()}

*qgmp_randseed =                      \&Math::GMPq::Random::Rgmp_randseed;
*qgmp_randseed_ui =                   \&Math::GMPq::Random::Rgmp_randseed_ui;
*qgmp_randclear =                     \&Math::GMPq::Random::Rgmp_randclear;
*qgmp_randinit_default =              \&Math::GMPq::Random::Rgmp_randinit_default;
*qgmp_randinit_mt =                   \&Math::GMPq::Random::Rgmp_randinit_mt;
*qgmp_randinit_lc_2exp =              \&Math::GMPq::Random::Rgmp_randinit_lc_2exp;
*qgmp_randinit_lc_2exp_size =         \&Math::GMPq::Random::Rgmp_randinit_lc_2exp_size;
*qgmp_randinit_set =                  \&Math::GMPq::Random::Rgmp_randinit_set;
*qgmp_randinit_default_nobless =      \&Math::GMPq::Random::Rgmp_randinit_default_nobless;
*qgmp_randinit_mt_nobless =           \&Math::GMPq::Random::Rgmp_randinit_mt_nobless;
*qgmp_randinit_lc_2exp_nobless =      \&Math::GMPq::Random::Rgmp_randinit_lc_2exp_nobless;
*qgmp_randinit_lc_2exp_size_nobless = \&Math::GMPq::Random::Rgmp_randinit_lc_2exp_size_nobless;
*qgmp_randinit_set_nobless =          \&Math::GMPq::Random::Rgmp_randinit_set_nobless;
*qgmp_urandomb_ui =                   \&Math::GMPq::Random::Rgmp_urandomb_ui;
*qgmp_urandomm_ui =                   \&Math::GMPq::Random::Rgmp_urandomm_ui;

1;

__END__

=head1 NAME

   Math::GMPq - perl interface to the GMP library's rational (mpq) functions.

=head1 DEPENDENCIES

   This module needs the GMP C library - available from:
   http://gmplib.org.

=head1 DESCRIPTION

   A bigrational module utilising the Gnu MP (GMP) library.
   Basically this module simply wraps all of the 'mpq'
   (rational number) functions provided by that library.
   The documentation below extensively plagiarises the GMP
   documentation (which can be found at http://gmplib.org).
   See also the Math::GMPq test suite for examples of usage.

   IMPORTANT:
    If your perl was built with '-Duse64bitint' you need to assign
    all integers larger than 52-bit in a 'use integer;' block.
    Failure to do so can result in the creation of the variable as
    an NV (rather than an IV) - with a resultant loss of precision.

=head1 SYNOPSIS

   use Math::GMPq qw(:mpq);

   my $str = '123542/4'; # numerator = 123542
                         # denominator = 4
   my $base = 10;

   # Create the Math::GMPq object
   my $bn1 = Rmpq_init(); # Value set to 0/1

   # Assign a value.
   Rmpq_set_str($str, $base);

   # Remove any factors common to both numerator and
   # denominator so that gcd(numerator, denominator) == 1.
   Rmpq_canonicalize($bn1);

   # or just use the new() function:
   my $rational = Math::GMPq->new('1234/1179');

   # Perform some operations, either by using function calls
   # or by utilising operator overloading ... see 'FUNCTIONS'
   # below.

   .
   .

   # print out the value held by $bn1 (in octal):
   print Rmpq_get_str($bn1, 8), "\n"; # prints '170513/2'

   # print out the value held by $bn1 (in decimal) with:
   print Rmpq_get_str($bn1, 10), "\n"; # prints '61771/2'.
   # or, courtesy of operator loading, simply with:
   print $bn1, "\n"; # again prints '61771/2'.

   # print out the value held by $bn1 (in base 29)
   # using the (alternative) Rmpq_out_str()
   # function. (This function doesn't print a newline.)
   Rmpq_out_str($bn1, 29);

=head1 MEMORY MANAGEMENT

   Objects created with Rmpq_create_init() have been
   blessed into package Math::GMPq. They will
   therefore be automatically cleaned up by the
   DESTROY() function whenever they go out of scope.

   If you wish, you can create unblessed objects
   with Rmpq_init_nobless().
   It will then be up to you to clean up the memory
   associated with these objects by calling
   Rmpq_clear($op), for each object.
   Alternatively the objects will be cleaned up
   when the script ends.
   I don't know why you would want to create unblessed
   objects - the point is you can if you want to :-)

=head1 FUNCTIONS

   See the GMP documentation at http://gmplib.org.

   These next 3 functions are demonstrated above:
   $rop   = Rmpq_init();
   $rop   = Rmpq_set_strl($str, $base); # 1 < $base < 63
   $str = Rmpq_get_str($op, $base); # 1 < $base < 37

   The following functions are simply wrappers around a GMP
   function of the same name. eg. Rmpq_swap() is a wrapper around
   mpq_swap() which is fully documented in the GMP manual at
   http://gmplib.org.

   "$rop", "$op1", "$op2", etc. are simply  Math::GMPq objects -
   the return value of Rmpq_init or Rmpq_init_nobless
   functions. They are in fact references to GMP structures.
   The "$rop" argument(s) contain the result(s) of the calculation
   being done, the "$op" argument(s) being the input(s) into that
   calculation.
   Generally, $rop, $op1, $op2, etc. can be the same perl variable,
   though usually they will be distinct perl variables referencing
   distinct GMP structures.
   Eg. something like Rmpq_add($r1, $r1, $r1),
   where $r1 *is* the same reference to the same GMP structure,
   would add $r1 to itself and store the result in $r1. Think of it
   as $r1 += $r1. Otoh, Rmpq_add($r1, $r2, $r3), where each of the
   arguments is a different reference to a different GMP structure
   would add $r2 to $r3 and store the result in $r1. Think of it as
   $r1 = $r2 + $r3. Mostly, the first argument is the argument that
   stores the result and subsequent arguments provide the input values.
   Exceptions to this can be found in some of the functions that
   actually return a value.
   Like I say, see the GMP manual for details. I hope it's
   intuitively obvious or quickly becomes so. Also see the test
   suite that comes with the distro for some examples of usage.

   "$ui" means any integer that will fit into a C 'unsigned long int.

   "$si" means any integer that will fit into a C 'signed long int'.

   "$double" means any number (not necessarily integer) that will fit
   into a C 'double'.

   "$bool" means a value (usually a 'signed long int') in which
   the only interest is whether it evaluates as true or false.

   "$str" simply means a string of symbols that represent a number,
   eg "1234567890987654321234567/7".
   Valid bases for GMP numbers are 2 to 62 (inclusive).

   ############

   CANONICALIZE

   Rmpq_canonicalize($op);
    Remove any factors that are common to the numerator and
    denominator of $op, and make the denominator positive.

   ##########

   INITIALIZE

   Normally, a variable should be initialized once only or at least be
   cleared, using `Rmpq_clear', between initializations.
   'DESTROY' (which calls 'Rmpq_clear') is automatically called on
   blessed objects whenever they go out of scope.

   See the section 'MEMORY MANAGEMENT' (above).

   $rop = Math::GMPq::new();
   $rop = Math::GMPq->new();
   $rop = new Math::GMPq();
   $rop = Rmpq_init();
   $rop = Rmpq_init_nobless();
    Initialize $rop and set it to 0/1.

   ####################

   ASSIGNMENT FUNCTIONS

   Rmpq_set($rop, $op);
   Rmpq_set_z($rop, $z); # $z is a Math::GMPz object
    Set $rop to value contained in 2nd arg.

   Rmpq_set_ui($rop, $ui1, $ui2);
   Rmpq_set_si($rop, $si1, $si2);
    Set $rop to 2nd arg / 3rd arg.

   Rmpq_set_str($rop, $str, $base);
    Set $rop from $str in the given base $base. The string can be
    an integer like "41" or a fraction like "41/152".  The fraction
    must be in canonical form, or if not then `Rmpq_canonicalize'
    must be called. The numerator and optional denominator are
    parsed the same as in `Rmpz_set_str'. $base can vary from 2 to
    62, or if $base is 0 then the leading characters are used: `0x'
    for hex, `0' for octal, or decimal otherwise.  Note that this
    is done separately for the numerator and denominator, so for
    instance `0xEF/100' is 239/100, whereas `0xEF/0x100' is 239/256.

   Rmpq_swap($rop1, $rop2);
    Swap the values.

   ####################

   COMBINED INITIALIZATION AND ASSIGNMENT

   NOTE: Do NOT use these functions if $rop has already
   been initialised. Instead use the Rmpq_set* functions
   in 'Assignment Functions' (above)

   First read the section 'MEMORY MANAGEMENT' (above).

   $rop = Math::GMPq->new($arg);
   $rop = Math::GMPq::new($arg);
   $rop = new Math::GMPq($arg);
    Returns a Math::GMPq object with the value of $arg.
    $arg can be either an integer (signed integer, unsigned
    integer) or a string that represents a numeric value. If $arg is a
    string, an optional additional argument that specifies the base of
    the number can be supplied to new(). If base is 0 (or not supplied)
    then the leading characters of the string are used: 0x or 0X for
    hex, 0b or 0B for binary, 0 for octal, or decimal otherwise. Note
    that this is done separately for the numerator and denominator, so
    for instance 0xEF/100 is 239/100, whereas 0xEF/0x100 is 239/256.
    Legal values for the base are 0 and 2..62.

   ####################

   RATIONAL CONVERSIONS

   $double = Rmpq_get_d($op);
    Convert $op to a 'double'.

   Rmpq_set_d($rop, $double);
   Rmpq_set_f($rop, $f); # $f is a Math::GnumMPf object
     Set $rop to the value of the 2nd arg, without rounding.

   $str = Rmpq_get_str($op, $base);
    Convert $op to a string of digits in base $base. The base may
    vary from 2 to 36.  The string will be of the form `num/den',
    or if the denominator is 1 then just `num'.

   ###################

   RATIONAL ARITHMETIC

   Rmpq_add($rop, $op1, $op2);
    $rop = $op1 + $op2.

   Rmpq_sub($rop, $op1, $op2);
    $rop = $op1 - $op2.

   Rmpq_mul($rop, $op1, $op2);
    $rop = $op1 * $op2.

   Rmpq_mul_2exp($rop, $op, $ui);
    $rop = $op * (2 ** $ui).

   Rmpq_div($rop, $op1, $op2);
    $rop = $op1 / $op2.

   Rmpq_div_2exp($rop, $op, $ui);
    $rop = $op / (2 ** $ui).

   Rmpq_neg($rop, $op);
    $rop = -$op.

   Rmpq_abs($rop, $op);
    $rop = abs($op).

   Rmpq_inv($rop, $op);
    $rop = 1 / $op.

   ##########################

   APPLYING INTEGER FUNCTIONS

   Rmpq_numref($z, $op); # $z is a Math::GMPz object
   Rmpq_denref($z, $op); # $z is a Math::GMPz object
    Set $rop to the numerator and denominator of $op, respectively.

   Rmpq_get_num($z, $op); # $z is a Math::GMPz oblect
   Rmpq_get_den($z, $op); # $z is a Math::GMPz oblect
   Rmpq_set_num($rop, $z); # $z is a Math::GMPz oblect
   Rmpq_set_den($rop, $z); # $z is a Math::GMPz oblect
    Get or set the numerator or denominator of a rational
    Direct use of `Rmpq_numref' or `Rmpq_denref' is
    recommended instead of these functions.

   ###################

   COMPARING RATIONALS

   $si = Rmpq_cmp($op1, $op2);
    Compare $op1 and $op2.  Return a positive value if $op1 > $op2,
    zero if $op1 = $op2, and a negative value if $op1 < $op2.
    To determine if two rationals are equal, `Rmpq_equal' is
    faster than `Rmpq_cmp'.

   $si = Rmpq_cmp_ui($op, $ui, $ui);
   $si1 = Rmpq_cmp_si($op, $si2, $ui);
    Compare $op1 and 2nd arg/3rd arg.  Return a positive value if
    $op1 > 2nd arg/3rd arg, zero if $op1 = 2nd arg/3rd arg,
    and a negative value if $op1 < 2nd arg/3rd arg.
    2nd and 3rd args are allowed to have common factors.
    Note that the 3rd (NOT 2nd) arg is unsigned. If you want
    to compare $op with 2/-3, make sure that 2nd arg is
    '-2' and 3rd arg is '3'.

   $si = Rmpq_sgn($op);
    Return +1 if $op>0, 0 if $op=0, and -1 if $op<0.

   $bool = Rmpq_equal($op1, $op2); # faster than Rmpq_cmp()
    Return non-zero if $op1 and $op2 are equal, zero if they
    are non-equal.  Although `Rmpq_cmp' can be used for the
    same purpose, this function is much faster.

   $si = Rmpq_cmp_z($op, $z);# $z is Math::GMPz or Math::GMP object
    Return a positive value if $op > $z.
    Return zero if $op == $z.
    Return a negative value if $op < $z.

   ################

   I/O of RATIONALS

   $bytes_written = Rmpq_out_str([$prefix,] $op, $base [, $suffix]);
    BEST TO USE TRmpq_out_str INSTEAD.
    Output $op to STDOUT, as a string of digits in base $base.
    The base may vary from 2 to 36. Output is in the form `num/den'
    or if the denominator is 1 then just `num'. Return the number
    of bytes written, or if an error occurred, return 0.
    The optional first and last arguments ($prefix and $suffix) are
    strings that will be prepended/appended to the mpq_out_str
    output.  $bytes_written does not include the bytes contained in
    $prefix and $suffix.

   $bytes_written = TRmpq_out_str([$prefix,] $stream, $base, $op, [, $suffix]);
    As for Rmpq_out_str, except that there's the capability to print
    to somewhere other than STDOUT. Note that the order of the args
    is different (to match the order of the mpq_out_str args).
    To print to STDERR:
       TRmpq_out_str(*stderr, $base, $digits, $op);
    To print to an open filehandle (let's call it FH):
       TRmpq_out_str(\*FH, $base, $digits, $op);

   $bytes_read = Rmpq_inp_str($rop, $base);
    BEST TO USE TRmpq_inp_str INSTEAD.
    Read a string of digits from STDIN and convert them to a rational
    in $rop.  Any initial white-space characters are read and
    discarded.  Return the number of characters read (including white
    space), or 0 if a rational could not be read.
    The input can be a fraction like `17/63' or just an integer like
    `123'.  Reading stops at the first character not in this form, and
    white space is not permitted within the string.  If the input
    might not be in canonical form, then `mpq_canonicalize' must be
    called. $base can be between 2 and 36, or can be 0 in which case the
    leading characters of the string determine the base, `0x' or `0X'
    for hexadecimal, `0' for octal, or decimal otherwise.  The leading
    characters are examined separately for the numerator and
    denominator of a fraction, so for instance `0x10/11' is 16/11,
    whereas `0x10/0x11' is 16/17.

   $bytes_read = TRmpq_inp_str($rop, $stream, $base);
    As for Rmpq_inp_str, except that there's the capability to read
    from somewhere other than STDIN.
    To read from STDIN:
       TRmpq_inp_str($rop, *stdin, $base);
    To read from an open filehandle (let's call it FH):
       TRmpq_inp_str($rop, \*FH, $base);

   #######################

   RANDOM NUMBER FUNCTIONS

   $state = qgmp_randinit_default();
    This is the Math::GMPq interface to the gmp library function
   'gmp_randinit_default'.
    $state is blessed into package Math::GMPq::Random and will be
    automatically cleaned up when it goes out of scope.
    Initialize $state with a default algorithm. This will be a
    compromise between speed and randomness, and is recommended for
    applications with no special requirements. Currently this is
    the gmp_randinit_mt function (Mersenne Twister algorithm).

   $state = qgmp_randinit_mt();
    This is the Math::GMPq interface to the gmp library function
   'gmp_randinit_mt'.
    Currently identical to fgmp_randinit_default().

   $state = qgmp_randinit_lc_2exp($mpz, $ui, $m2exp);
    This is the Math::GMPq interface to the gmp library function
    'gmp_randinit_lc_2exp'. $mpz is a Math::GMP or Math::GMPz object,
    so one of those modules is required in order to make use of this
    function.
    $state is blessed into package Math::GMPq::Random and will be
    automatically cleaned up when it goes out of scope.
    Initialize $state with a linear congruential algorithm
    X = ($mpz*X + $ui) mod (2 ** $m2exp). The low bits of X in this
    algorithm are not very random. The least significant bit will have a
    period no more than 2, and the second bit no more than 4, etc. For
    this reason only the high half of each X is actually used.
    When a random number of more than m2exp/2 bits is to be generated,
    multiple iterations of the recurrence are used and the results
    concatenated.

   $state = qgmp_randinit_lc_2exp_size($ui);
    This is the Math::GMPq interface to the gmp library function
   'gmp_randinit_lc_2exp_size'.
    $state is blessed into package Math::GMPf::Random and will be
    automatically cleaned up when it goes out of scope.
    Initialize state for a linear congruential algorithm as per
    gmp_randinit_lc_2exp. a, c and m2exp are selected from a table,
    chosen so that $ui bits (or more) of each X will be used,
    ie. m2exp/2 >= $ui.
    If $ui is bigger than the table data provides then the function fails
    and dies with an appropriate error message. The maximum value for $ui
    currently supported is 128.

   $state2 = qgmp_randinit_set($state1);
    This is the Math::GMPq interface to the gmp library function
   'gmp_randinit_set'.
    $state2 is blessed into package Math::GMPf::Random and will be
    automatically cleaned up when it goes out of scope.
    Initialize $state2 with a copy of the algorithm and state from
    $state1.

   $state = qgmp_randinit_default_nobless();
   $state = qgmp_randinit_mt_nobless();
   $state = qgmp_randinit_lc_2exp_nobless($mpz, $ui, $m2exp);
   $state2 = qgmp_randinit_set_nobless($state1);
    As for the above comparable function, but $state is not blessed into
    any package. (Generally not useful - but they're available if you
    want them.)

   qgmp_randseed($state, $mpz); # $mpz is a Math::GMPz or Math::GMP object
   qgmp_randseed_ui($state, $ui);
    These are the Math::GMPz interfaces to the gmp library functions
    'gmp_randseed' and 'gmp_randseed_ui'.
    Seed an initialised (but not yet seeded) $state with $mpz/$ui.
    Either Math::GMP or Math::GMPz is required for 'gmp_randseed'.

   $ui = qgmp_urandomb_ui($state, $bits);
    This is the Math::GMPq interface to the gmp library function
    'gmp_urandomb_ui'.
    Return a uniformly distributed random number of $bits bits, ie. in
    the range 0 to 2 ** ($bits - 1) inclusive. $bits must be less than or
    equal to the number of bits in an unsigned long.

   $ui2 = qgmp_urandomm_ui($state, $ui1);
    This is the Math::GMPq interface to the gmp library function
    'gmp_urandomm_ui'.
    Return a uniformly distributed random number in the range 0 to
    $ui1 - 1, inclusive.

   qgmp_randclear($state);
    Destroys $state, as also does Math::GMPq::Random::DESTROY - two
    identical functions.
    Use only if $state is an unblessed object - ie if it was initialised
    using one of the qgmp_randinit*_nobless functions.

   ####################

   OPERATOR OVERLOADING

   Overloading occurs with numbers, strings,Math::GMPq objects and, to a
   limited extent, Math::GMP or Math::GMPz objects (iff the gmp library is
   version 6.1.0 or later) and Math::MPFR objects (iff version 3.13 or
   later of Math::MPFR has been installed).
   Strings are first converted to Math::GMPq objects, then canonicalized.
   See the Rmpq_set_str documentation (above) in the section "ASSIGNMENT
   FUNCTIONS" regarding permissible string formats.
   The following operators are overloaded:

    + - * /
    += -= *= /= ++ --
    == != !
    < <= > >= <=>
    = "" abs

    Atempting to use the overloaded operators with objects that
    have been blessed into some package other than 'Math::GMPq'
    or 'Math::MPFR' (limited applications) will not work.
    Math::MPFR objects can be used only with '+', '-', '*', '/'
    and '**' operators, and will work only if Math::MPFR is at
    version 3.13 or later - in which case the operation will
    return a Math::MPFR object.
    Math::GMP or Math::GMPz objects can be used only with the
    comparison operators ( == != < <= > >= <=> ), and only if Math::GMPq
    has been built against gmp-6.1.0 or later.
    In those situations where the overload subroutine operates on 2
    perl variables, then obviously one of those perl variables is
    a Math::GMPq object. To determine the value of the other variable
    the subroutine works through the following steps (in order),
    using the first value it finds, or croaking if it gets
    to step 6:

    1. If the variable is an unsigned long then that value is used.
       The variable is considered to be an unsigned long if
       (perl 5.8 and later) the UOK flag is set or if (perl 5.6)
       SvIsUV() returns true.

    2. If the variable is a signed long int, then that value is used.
       The variable is considered to be a signed long int if the
       IOK flag is set. (In the case of perls built with
       -Duse64bitint, the variable is treated as a signed long long
       int if the IOK flag is set.)

    3. If the variable is a double, then that value is used. The
       variable is considered to be a double if the NOK flag is set.

    4. If the variable is a string (ie the POK flag is set) then the
       value of that string is used. Octal strings must begin with
       '0', hex strings must begin with either '0x' or '0X' -
       otherwise the string is assumed to be decimal. If the POK
       flag is set, but the string is not a valid base 8, 10, or 16
       number, the subroutine croaks with an appropriate error
       message. If the string is of the form 'numerator/denominator',
       then the bases of the numerator and the denominator are
       assessed individually. ie '0xa123/ff' is not a valid number
       (because 'ff' is not a valid base 10 number). That needs to
       be rewritten as '0xa123/0xff'.

    5. If the variable is a Math::GMPq object (or, for operators
       specified above, a Math::MPFR/Math::GMP/Math::GMPz object)
       then the value of that object is used.

    6. If none of the above is true, then the second variable is
       deemed to be of an invalid type. The subroutine croaks with
       an appropriate error message.

   ##############

   MISCELLANEOUS

   $bool = Rmpq_integer_p($op);
    Returns true if $op is an integer (ie denominator of $op is 1).
    Else returns false. The mpq_integer_p function is not
    implemented in gmp.

   #####

   OTHER

   $GMP_version = Math::GMPq::gmp_v;
    Returns the version of the GMP library (eg 4.1.3) being used by
    Math::GMPq. The function is not exportable.

   $GMP_cc = Math::GMPq::__GMP_CC;
   $GMP_cflags = Math::GMPq::__GMP_CFLAGS;
    If Math::GMPq has been built against gmp-4.2.3 or later,
    returns respectively the CC and CFLAGS settings that were used
    to compile the gmp library against which Math::GMPq was built.
    (Values are as specified in the gmp.h that was used to build
    Math::GMPq.)
    Returns undef if Math::GMPq has been built against an earlier
    version of the gmp library.
    (These functions are in @EXPORT_OK and are therefore exportable
    by request. They are not listed under the ":mpq" tag.)

   $major = Math::GMPq::__GNU_MP_VERSION;
   $minor = Math::GMPq::__GNU_MP_VERSION_MINOR;
   $patchlevel = Math::GMPq::__GNU_MP_VERSION_PATCHLEVEL;
    Returns respectively the major, minor, and patchlevel numbers
    for the GMP library version used to build Math::GMPq. Values are
    as specified in the gmp.h that was used to build Math::GMPq.
    (These functions are in @EXPORT_OK and are therefore exportable
    by request. They are not listed under the ":mpq" tag.)

   ################

   FORMATTED OUTPUT

   NOTE: The format specification can be found at:
   http://gmplib.org/manual/Formatted-Output-Strings.html#Formatted-Output-Strings
   However, the use of '*' to take an extra variable for width and
   precision is not allowed in this implementation. Instead, it is
   necessary to interpolate the variable into the format string - ie,
   instead of:
     Rmpq_printf("%*Zd\n", $width, $mpz);
   we need:
     Rmpq_printf("%${width}Zd\n", $mpz);

   $si = Rmpq_printf($format_string, $var);

    This function changed with the release of Math-GMPq-0.27.
    Now (unlike the GMP counterpart), it is limited to taking 2
    arguments - the format string, and the variable to be formatted.
    That is, you can format only one variable at a time.
    If there is no variable to be formatted, then the final arg
    can be omitted - a suitable dummy arg will be passed to the XS
    code for you. ie the following will work:
     Rmpq_printf("hello world\n");
    Returns the number of characters written, or -1 if an error
    occurred.

   $si = Rmpq_fprintf($fh, $format_string, $var);

    This function (unlike the GMP counterpart) is limited to taking
    3 arguments - the filehandle, the format string, the variable
    to be formatted. That is, you can format only one variable at a time.
    If there is no variable to be formatted, then the final arg
    can be omitted - a suitable dummy arg will be passed to the XS
    code for you. ie the following will work:
     Rmpq_fprintf($fh, "hello world\n");
    Other than that, the rules outlined above wrt Rmpq_printf apply.
    Returns the number of characters written, or -1 if an error
    occurred.

   $si = Rmpq_sprintf($buffer, $format_string, $var, $buflen);

    This function (unlike the GMP counterpart) is limited to taking
    4 arguments - the buffer, the format string,  the variable to be
    formatted and the size of the buffer. If there is no variable to
    be formatted, then the third arg can be omitted - a suitable
    dummy arg will be passed to the XS code for you. ie the following
    will work:
     Rmpf_sprintf($buffer, "hello world", 12);
    $buffer must be large enough to accommodate the formatted string.
    The formatted string is placed in $buffer.
    Returns the number of characters written, or -1 if an error
    occurred.

   $si = Rmpq_snprintf($buffer, $bytes, $format_string, $var, $buflen);

    Form a null-terminated string in $buffer. No more than $bytes
    bytes will be written. To get the full output, $bytes must be
    enough for the string and null-terminator. $buffer must be large
    enough to accommodate the string and null-terminator, and is
    truncated to the length of that string (and null-terminator).
    The return value is the total number of characters which ought
    to have been produced, excluding the terminating null.
    If $si >= $bytes then the actual output has been truncated to
    the first $bytes-1 characters, and a null appended.
    This function (unlike the GMP counterpart) is limited to taking
    5 arguments - the buffer, the maximum number of bytes to be
    returned, the format string, the variable to be formatted and
    the size of the buffer.
    If there is no variable to be formatted, then the 4th arg can
    be omitted - a suitable dummy arg will be passed to the XS code
    for you. ie the following will work:
     Rmpf_snprintf($buffer, 6, "hello world", 12);

   ################
   ################

=head1 BUGS

    You can get segfaults if you pass the wrong type of
    argument to the functions - so if you get a segfault, the
    first thing to do is to check that the argument types
    you have supplied are appropriate.

=head1 LICENSE

    This program is free software; you may redistribute it and/or
    modify it under the same terms as Perl itself.
    Copyright 2006-2011, 2013-16, Sisyphus

=head1 AUTHOR

    Sisyphus <sisyphus at(@) cpan dot (.) org>


=cut
