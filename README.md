SendDirectoryWithMail
=====================

Perl scripts to send and receive a directory with eMail.

[`send_directory_via_mail.pl`](https://github.com/ReneNyffenegger/SendDirectoryWithMail/blob/master/send_directory_via_mail.pl) zips a directory and sends it perl mail
to a specified receiver. Some companies have policies that wouldn't let receive mails that contain `*.dll`, `*.exe`, `*.bat` etc, even if these files are zipped.
Therefore, the script changes the suffix of these files so that they can get through.

    
    send_directory_via_mail.pl c:\path\to\directory sender.email@somewhere.foo mail.server.foo receiver.email@somewhere.else.bar authenticationForMailServer


[`receive_directory_from_outlook.pl`](https://github.com/ReneNyffenegger/SendDirectoryWithMail/blob/master/receive_directory_from_outlook.pl) get the zip file
from Outlook, extracts it and changes the changed suffixes to their original.


    receive_directory_from_outlook.pl c:\path\to\destination\directory
