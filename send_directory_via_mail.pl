use warnings;
use strict;

use Archive::Zip qw(:ERROR_CODES :CONSTANTS);

use File::Spec::Functions qw(tmpdir abs2rel);
use File::Basename;
use File::Find;

use Email::Stuffer;
use Email::Sender::Transport::SMTP;

my $file_or_dir_to_send    = shift;

my $sender_mail_address    = shift;
my $smtp_server            = shift;
my $recipient_mail_address = shift;
my $auth_passwd            = shift;

my $subject                = 'yyoouu ggoott mmaaiill';

die "$file_or_dir_to_send does not exist" unless -e $file_or_dir_to_send;

my $zip = new Archive::Zip;

if    (-f $file_or_dir_to_send) {
  $zip -> addFile($file_or_dir_to_send);
}
elsif (-d $file_or_dir_to_send) {
  add_files_recursively($zip, $file_or_dir_to_send);
}

my $zip_file_name = tmpdir . '\file_to_send.zip';
$zip -> writeToFileNamed ($zip_file_name) == AZ_OK or die "Could not write $zip_file_name";

print "\n  $zip_file_name written\n";

send_($sender_mail_address   ,  # from
      $recipient_mail_address,  # to
      $subject               ,  # subject
      $smtp_server           ,  # host
      $sender_mail_address   ,  # sasl_user
      $auth_passwd           ,  # sasl_pd
      $zip_file_name            # attachment
);

print "\n  Mail sent\n";



sub add_files_recursively { # {{{

  my $zip = shift;
  my $dir = shift;

  find (sub {

    return unless -f $File::Find::name;

    my $relative_file_name = abs2rel($File::Find::name, $dir);

    $relative_file_name =~ s/\.exe$/.eggse/;
    $relative_file_name =~ s/\.dll$/.dee-ell-ell/;
    $relative_file_name =~ s/\.pl$/.pee-ell/;
    $relative_file_name =~ s/\.bat$/.6at/;

    my $zip_member = $zip -> addFile($File::Find::name, $relative_file_name);

    $zip_member -> desiredCompressionLevel(COMPRESSION_LEVEL_BEST_COMPRESSION);

  }, $dir);
    
} # }}}

sub send_ { # {{{

    my $from       = shift;
    my $to         = shift;
    my $subject    = shift;
    my $host       = shift;
    my $sasl_user  = shift;
    my $sasl_pw    = shift;
    my $attachment = shift;


    Email::Stuffer ->
      from       ( $from                    ) -> 
      to         ( $to                      ) ->
      subject    ( $subject                 ) ->
      text_body  ("Hi\n\nAttached is a file") ->
      attach_file( $attachment              ) ->
      transport  ( Email::Sender::Transport::SMTP -> new ({
                     host             => $host,
                   # port             =>  25,
                     sasl_username    => $sasl_user, # ?
                     sasl_password    => $sasl_pw })
                 )
    ->send or die "could not send message $!";

    
} # }}}
