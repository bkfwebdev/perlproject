#!/usr/bin/perl -w
# A perlscript written by Joseph Hughes, University of Glasgow
# use this perl script to parse the email addressed from the affiliations in PubMed
use strict;
use LWP::Simple;
my ($query,@queries);
#Query the Journal of Virology from 2014 until the present (use 3000)
$query = &#39;journal+of+virology[journal]+AND+2014[Date+-+Publication]:3000[Date+- +Publication]&#39;;
push(@queries,$query);
#Journal of General Virology
$query = &#39;journal+of+general+virology[journal]+AND+2014[Date+-+Publication]:3000[Date+-
+Publication]&#39;;
push(@queries,$query);
#Virology
$query = &#39;virology[journal]+AND+2014[Date+-+Publication]:3000[Date+- +Publication]&#39;;
push(@queries,$query);
#Archives of Virology
$query = &#39;archives+of+virology[journal]+AND+2014[Date+-+Publication]:3000[Date+- +Publication]&#39;;
push(@queries,$query);
#Virus Research
$query = &#39;virus+research[journal]+AND+2014[Date+-+Publication]:3000[Date+- +Publication]&#39;;
push(@queries,$query);
#Antiviral Research
$query = &#39;antiviral+research[journal]+AND+2014[Date+-+Publication]:3000[Date+- +Publication]&#39;;
push(@queries,$query);
#Viruses
$query = &#39;viruses[journal]+AND+2014[Date+-+Publication]:3000[Date+- +Publication]&#39;;
push(@queries,$query);
#Journal of Medical Virology
$query = &#39;journal+of+medical+virology[journal]+AND+2014[Date+-+Publication]:3000[Date+-
+Publication]&#39;;
# global variables
push(@queries,$query);

my %emails;
my $emailcnt=0;
my $count=1;
#assemble the esearch URL
foreach my $query (@queries){
my $base = &#39;http://eutils.ncbi.nlm.nih.gov/entrez/eutils/&#39;;
my $url = $base . &quot;esearch.fcgi?db=pubmed&amp;term=$query&amp;usehistory=y&quot;;
#post the esearch URL
my $output = get($url);
#parse WebEnv, QueryKey and Count (# records retrieved)
my $web = $1 if ($output =~ /&lt;WebEnv&gt;(\S+)&lt;\/WebEnv&gt;/);
my $key = $1 if ($output =~ /&lt;QueryKey&gt;(\d+)&lt;\/QueryKey&gt;/);
my $count = $1 if ($output =~ /&lt;Count&gt;(\d+)&lt;\/Count&gt;/);
#retrieve data in batches of 500
my $retmax = 500;
for (my $retstart = 0; $retstart &lt; $count; $retstart += $retmax) {
my $efetch_url = $base .&quot;efetch.fcgi?db=pubmed&amp;WebEnv=$web&quot;;
$efetch_url .= &quot;&amp;query_key=$key&amp;retmode=xml&quot;;
my $efetch_out = get($efetch_url);
my @matches = $efetch_out =~ m(&lt;Affiliation&gt;(.*)&lt;/Affiliation&gt;)g;
#print &quot;$_\n&quot; for @matches;
for my $match (@matches){
if ($match=~/\s([a-zA- Z0-9\.\_\- ]+\@[a-zA- Z0-9\.\_\- ]+)$/){
my $email=$1;
$email=~s/\.$//;
$emails{$email}++;
}
}
}
my $cnt= keys %emails;
print &quot;$query\n$cnt\n&quot;;
}
print &quot;Total number of emails: &quot;;
my $cnt= keys %emails;
print &quot;$cnt\n&quot;;
my @email = keys %emails;
my @VAR;
push @VAR, [ splice @email, 0, 100 ] while @email;
my $batch=100;
foreach my $VAR (@VAR){
open(OUT, &quot;&gt;Set_$batch\.txt&quot;) || die &quot;Can&#39;t open file!\n&quot;;
print OUT join(&quot;,&quot;,@$VAR);
close OUT;
$batch=$batch+100;
}