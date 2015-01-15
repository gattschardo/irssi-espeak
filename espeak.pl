use strict;
use vars qw($VERSION %IRSSI);
use Irssi qw(command_bind signal_add);

use Irssi;
$VERSION = '0.2';
%IRSSI = (
  authors     => 'Richard Molitor',
  contact     => 'gattschardo@yahoo.de',
  name	      => 'espeak',
  description => 'This script provides'.
                 'text to speech functionality'.
                 'via espeak',
  license     => 'MIT',
);
my $espeak_args = " -v de -s 140 ";

my $subs = {
  '_'   => ' Unterstrich ',
 'ä'   => 'ae',
  'äu'  => 'eu',
  'ö'   => 'oe',
  'ü'   => 'ue',
  'ß'   => 'ss',
  '\''  => ' ',
  '/'	=> ' ',
  '"'   => ' ',
# '\?'  => '\\?'
};

my $chan_subs = {
  '\#'  => '',
  '\&'  => ''
};

my $speech_subs = {
  # general
  ';'       => ' Semikolon ',
  '\('      => ' ',
  '\)'      => ' ',
  #'\('      => ' Klammer auf ',
  #'\)'      => ' Klammer zu ',
  '#' 	    => ' Raute ',
  '\|'      => ' Paip ',
  '\+'      => ' Plus ',
  '\-'      => ' Minus ',
  '€'       => ' Euro ',
  'd\.h\.'  => ' das heisst ',
  '[^a-z]mom|^mom$' => ' Moment ',
  '@'       => ' aet ',
  '='       => ' gleich ',
  '\*'      => ' Sternchen ',
  'kA'      => ' keine Ahnung ',
  'KA'      => ' Karlsruhe ',
  '(^|[^a-z])k([^a-zA-Z]|$)'  => ' key ',
  '(^|[^a-z])hi([^a-z]|$)' => ' hai ',
  '\.de'    => ' D E ',
  'vll[t]*' => ' vielleicht ',
  '19\d{2}([^0-9]|$)' => ' neunzehnhundert ',
  # dirty hacks to convert German to English
  'nice'    => 'nais',
  'user'    => 'juser',
  'bool'    => 'bul',
  # the not so dirty 'remove-all-smilies' part
  ':\)'     => '',
  ':-\)'    => '',
  'XD'      => '',
  'xD'      => '',
  ':D'      => '',
  ':-D'     => '',
  ':P'      => '',
  ':/'      => '',
  ':-/'     => '',
  ':\\\\'   => '',
  ':-\\\\'  => ''
};

my $nick_subs = {
  'n0nsense'  => 'nonsens',
  'McManiaC'  => 'mecmeyniac',
  'w33z4l'    => 'wiesal',
  'LucY'      => 'luhssi',
  'anoobis'   => 'anubis',
  'bugfeed'   => 'bagfied',
  'm0l0t0ph'  => 'toff',
  'cereal'    => 'ssiriel',
  'root'      => 'rut',
  'JJ'        => 'jehi jehi',
  '\|'        => '',
  '_'	      => ' '
};

sub _cleaner {
  $_ = shift;
  while ( my($key, $value) = each %$subs) {
    s/$key/$value/g;
  }
  /([\w\d\ \.\:\;\,\!\$\%\&\*\^\'\=]*)/;
  return $1;
}

sub _chan_cleaner {
  $_ = shift;
  while ( my($key, $value) = each %$chan_subs) {
    s/$key/$value/g;
  }
  &_cleaner($_);
}

sub _speech_cleaner {
  $_ = shift;
  while ( my($key, $value) = each %$speech_subs) {
    s/$key/$value/g;
  }
  &_cleaner($_);
  &_nick_cleaner($_);
}

sub _nick_cleaner {
  $_ = shift;
  while ( my($key, $value) = each %$nick_subs) {
    s/$key/$value/g;
  }
  &_cleaner($_);
}

sub _privmsg {
  # $data = "nick/#channel :text"
  my ($server, $data, $nick, $address) = @_;
  my ($target, $text) = split(/ :/, $data, 2);
  my $nick_c = &_nick_cleaner($nick);
  my $text_c = &_speech_cleaner($text);
  my $target_c = &_chan_cleaner($target);

  if (length($text_c) > 0) {
    if (substr ($text,-1,1) eq '?') {
      system("flock $ENV{'HOME'}/.irssi/scripts/.espeak.lock ".
          "-c \'espeak $espeak_args \"$nick_c".
          " fragt $text_c\"\' &");
    }
    else {
      system("flock $ENV{'HOME'}/.irssi/scripts/.espeak.lock ".
          "-c \'espeak $espeak_args \"$nick_c".
          " sagt $text_c\"\' &");
    }
  }
}

sub _join {
  my ($server, $channel, $nick, $address) = @_;
  my $channel_c = &_chan_cleaner($channel);
  my $nick_c = &_nick_cleaner($nick);

  #print("$nick_c joined");
  #system("espeak $espeak_args \"$nick_c".
  #" hat $channel_c betreten.\" &");
}

signal_add("event privmsg", "_privmsg");
signal_add("message join", "_join");
