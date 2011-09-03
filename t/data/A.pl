use strict;

package A;

package B;
use parent -norequire, 'A';

package C;
our @ISA = 'A';

package D;
use base 'C';

package main;
our @ISA = D::;
exit;
