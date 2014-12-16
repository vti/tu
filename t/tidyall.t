use strict;
use warnings;

use Test::Requires;

BEGIN { test_requires 'Test::Code::TidyAll' }

use Test::Code::TidyAll;

tidyall_ok();
