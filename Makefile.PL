use inc::Module::Install;
name           'Nagios-Plugin-Solaris-CheckRAIDctl';
author         'Takuya Tsuchida tsucchi@cpan.org';
license        'perl';
all_from       'lib/Nagios/Plugin/Solaris/CheckRAIDctl.pm';

author_tests   'xt';
test_requires  'Test::More'  => '0.88';   # want to use done_testing()
requires       'Nagios::Plugin';
WriteAll;
