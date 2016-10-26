
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "LIMS2 REST Client",
  "AUTHOR" => "Ray Miller <rm7\@sanger.ac.uk>",
  "BUILD_REQUIRES" => {
    "Const::Fast" => 0,
    "English" => 0,
    "File::Find" => 0,
    "File::Temp" => 0,
    "FindBin" => 0,
    "Test::More" => "0.88",
    "Test::Most" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "LIMS2-REST-Client",
  "EXE_FILES" => [
    "bin/lims2-rest-client"
  ],
  "LICENSE" => "perl",
  "NAME" => "LIMS2::REST::Client",
  "PREREQ_PM" => {
    "Data::Dump" => 0,
    "Data::Serializer" => 0,
    "Getopt::Long" => 0,
    "HTTP::Request" => 0,
    "HTTP::Status" => 0,
    "JSON" => 0,
    "LWP::UserAgent" => 0,
    "Log::Log4perl" => 0,
    "Moose" => 0,
    "MooseX::Getopt" => 0,
    "MooseX::Log::Log4perl" => 0,
    "MooseX::MarkAsMethods" => 0,
    "MooseX::SimpleConfig" => 0,
    "MooseX::Types::URI" => 0,
    "Scalar::Util" => 0,
    "Throwable" => 0,
    "Try::Tiny" => 0,
    "URI" => 0,
    "YAML::Tiny" => 0,
    "namespace::autoclean" => 0,
    "overload" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "VERSION" => "0.004",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



