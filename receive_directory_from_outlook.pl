use warnings;
use strict;

use Win32::OLE; # qw (in with)
use Win32::OLE::Const 'Microsoft Outlook';
use Win32::OLE::Variant;

use File::Copy;
use File::Spec::Functions qw(tmpdir);
use File::Find;

use Archive::Extract;

my $dest_dir = shift or die "Missing destination directory";

die "$dest_dir already exists" if -e $dest_dir;

my $OL = Win32::OLE->GetActiveObject('Outlook.Application') || Win32::OLE->new('Outlook.Application', 'Quit');

die unless $OL;

my $NameSpace = $OL->GetNameSpace("MAPI") or die;

my $Folder = $NameSpace->GetDefaultFolder(olFolderInbox);

foreach my $msg (reverse Win32::OLE::in($Folder->{Items})) { # {{{ Find newest message with desired attachment


  if ($msg->{subject} =~ /yyoouu ggoott mmaaiill/) {
     print "\n  Found $msg->{subject} of $msg->{Creationtime}\n";

     process_attachment($msg, $dest_dir);
     exit;
  }

} # }}}

sub process_attachment { # {{{

    my $msg      = shift;
    my $dest_dir = shift;


  # There should be only one attachment, so instead of iterating
  # over the array returned by *...in, we just get the first
  #(and only?) attachment:

    my $attachment = (Win32::OLE::in($msg->{Attachments}))[0];
    my $zip_dest   = tmpdir . "\\" . $attachment->{Filename};


    $attachment -> SaveAsFile($zip_dest);

    print "\n  $zip_dest written\n";

    my $unzip = new Archive::Extract(archive => $zip_dest);
    $unzip->extract(to=>$dest_dir) or die "Could not extract $zip_dest to $dest_dir!";

    print "\n  $zip_dest extracted to $dest_dir\n";

      
    find (sub {

       return unless -f $File::Find::name;

       my $new_file_name = $File::Find::name;

       $new_file_name =~ s/\.eggse$/.exe/;
       $new_file_name =~ s/\.dee-ell-ell/.dll/;
       $new_file_name =~ s/\.pee-ell/.pl/;
       $new_file_name =~ s/\.6at/.bat/;

       if ($File::Find::name ne $new_file_name) {
#        printf "%60s -> %60s\n", $File::Find::name , $new_file_name;
         move ($File::Find::name, $new_file_name);
       }

    }, $dest_dir);

    print "\n  suffixes reset\n";

    
} # }}}
