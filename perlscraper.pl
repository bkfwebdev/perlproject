#!/usr/bin/perl -w
# A perlscript written by Joseph Hughes, University of Glasgow
# use this perl script to parse the email addressed from the affiliations in PubMed

use strict;
use LWP::Simple;

my ($query,@queries);
#Query the Journal of Virology from 2014 until the present (use 3000)
$query = 'journal+of+virology[journal]+AND+2014[Date+-+Publication]:3000[Date+-+Publication]';
push(@queries,$query);
#Journal of General Virology
$query = 'journal+of+general+virology[journal]+AND+2014[Date+-+Publication]:3000[Date+-+Publication]';
push(@queries,$query);
#Virology
$query = 'virology[journal]+AND+2014[Date+-+Publication]:3000[Date+-+Publication]';
push(@queries,$query);
#Archives of Virology
$query = 'archives+of+virology[journal]+AND+2014[Date+-+Publication]:3000[Date+-+Publication]';
push(@queries,$query);
#Virus Research
$query = 'virus+research[journal]+AND+2014[Date+-+Publication]:3000[Date+-+Publication]';
push(@queries,$query);
#Antiviral Research
$query = 'antiviral+research[journal]+AND+2014[Date+-+Publication]:3000[Date+-+Publication]';
push(@queries,$query);
#Viruses
$query = 'viruses[journal]+AND+2014[Date+-+Publication]:3000[Date+-+Publication]';
push(@queries,$query);
#Journal of Medical Virology
$query = 'journal+of+medical+virology[journal]+AND+2014[Date+-+Publication]:3000[Date+-+Publication]';

# global variables
push(@queries,$query);
my %emails;
my $emailcnt=0;
my $count=1;
#assemble the esearch URL
foreach my $query (@queries){
  my $base = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/';
  my $url = $base . "esearch.fcgi?db=pubmed&term=$query&usehistory=y";
  #post the esearch URL
  my $output = get($url);
  #parse WebEnv, QueryKey and Count (# records retrieved)
  my $web = $1 if ($output =~ /<WebEnv>(\S+)<\/WebEnv>/);
  my $key = $1 if ($output =~ /<QueryKey>(\d+)<\/QueryKey>/);
  my $count = $1 if ($output =~ /<Count>(\d+)<\/Count>/);

  #retrieve data in batches of 500
  my $retmax = 500;
  for (my $retstart = 0; $retstart < $count; $retstart += $retmax) {
    my $efetch_url = $base ."efetch.fcgi?db=pubmed&WebEnv=$web";
    $efetch_url .= "&query_key=$key&retmode=xml";
    my $efetch_out = get($efetch_url);
    my @matches = $efetch_out =~ m(<Affiliation>(.*)</Affiliation>)g;
    #print "$_\n" for @matches;
    for my $match (@matches){
      if ($match=~/\s([a-zA-Z0-9\.\_\-]+\@[a-zA-Z0-9\.\_\-]+)$/){
        my $email=$1;
        $email=~s/\.$//;
        $emails{$email}++;
      }     
    }
  }
  my $cnt= keys %emails;
  print "$query\n$cnt\n";
}

print "Total number of emails: ";
my $cnt= keys %emails;
print "$cnt\n";
my @email = keys %emails;
my @VAR;
push @VAR, [ splice @email, 0, 100 ] while @email;

my $batch=100;
foreach my $VAR (@VAR){
    open(OUT, ">Set_$batch\.txt") || die "Can't open file!\n";
    print OUT join(",",@$VAR);
    close OUT;
    $batch=$batch+100;
}    
