######################################### 	
#    CSCI 305 - Programming Lab #1		
#										
#  < Joshua Leger >			
#  < legerjoshua@rocketmail.com >			
#										
#########################################

# Replace the string value of the following variable with your names.
my $name = "Joshua Leger";
print "CSCI 305 Lab 1 submitted by $name.\n\n";

# Checks for the argument, fail if none given
if($#ARGV != 0) {
    print STDERR "You must specify the file name as the argument.\n";
    exit 4;
}

# Opens the file and assign it to handle INFILE
open(INFILE, $ARGV[0]) or die "Cannot open $ARGV[0]: $!.\n";

# Bigram model is a hash where key is a string that is the word and value is a 
# reference to another hash
# The reference hash has a key of a string that is the following word and a value of how
# many times encoutered.
%bigrams = ();

# This loops through each line of the file
while($line = <INFILE>)
{
    # Remove the unwanted data from the title
    my ($title) = ($line =~ m/.*<SEP>.*<SEP>.*<SEP>(.*)/);
    $title =~ s/[([{\\\/_\-:"`+=*].*//;
    $title =~ s/feat\..*//;
    $title =~ s/[?¿!¡.;&\$\@%#|]//g;
    # If the title contains only english letters
    if($title !~ m/[^\w\s']/)
    {
        $title = lc $title;

        my @title_words = split(' ', $title);
        my $last_word = "";

        # Go through each word and update the bigram structure
        foreach $word (@title_words)
        {
            # If stop word, skip
            if($word ne "a" and $word ne "an" and $word ne "and" and $word ne "by" and
               $word ne "for" and $word ne "from" and $word ne "in" and $word ne "of" and
               $word ne "on" and $word ne "or" and $word ne "out" and $word ne "the" and
               $word ne "to" and $word ne "with")
            {
                if($last_word eq "")
                {
                    $last_word = $word;
                }
                else
                {
                    # If new following word
                    if(!exists($bigrams{$last_word}))
                    {
                        my $inner_bigram = {$word => 1};
                        $bigrams{$last_word} = $inner_bigram;
                    }
                    # Otherwise increment times seen by 1
                    else
                    {
                        my $inner_bigram = $bigrams{$last_word};
                        if(!exists($inner_bigram->{$word}))
                        {
                            $inner_bigram->{$word} = 1;
                        }
                        else
                        {
                            $inner_bigram->{$word}++;
                        }
                    }
                    $last_word = $word;
                }
            }
        }
    }
}

# Close the file handle
close INFILE; 

# At this point (hopefully) you will have finished processing the song 
# title file and have populated your data structure of bigram counts.
print "File parsed. Bigram model built.\n\n";


# User control loop
print "Enter a word [Enter 'q' to quit]: ";
$input = <STDIN>;
chomp($input);
print "\n";	
while ($input ne "q")
{
    my $title = $input;
    my $last_word = $input;
    my $words = 0;

    # Makes sure output doesn't explode
    while($words < 20)
    {
        $last_word = mcw($last_word);

        my @title_words = split(' ', $title);

        # Check to make sure word not repeated
        # If repeated, finishes title
        foreach $word (@title_words)
        {
            if($last_word eq $word)
            {
                $last_word = "";
                last;
            }
        }

        # If no following word, exit
        if($last_word eq "")
        {
            last;
        }
        else
        {
            $title = $title . " " . $last_word;
            $words++;
        }
    }
    
    print $title . "\n";

    print "Enter a word [Enter 'q' to quit]: ";
    $input = <STDIN>;
    chomp($input);
    print "\n";	
}

# Finds the next most popular word
# Takes one string as input
sub mcw
{
    $word = @_[0];
    $inner = $bigrams{$word};
    $best_word = "";
    $best_word_count = -1;

    # Go through each following word
    while(my ($key, $value) = each(%$inner))
    {
        # If bigger, replace
        if($value > $best_word_count)
        {
            $best_word = $key;
            $best_word_count = $value;
        }
        # If same size, coin toss to replace
        if($value == $best_word_count and rand(2) == 0)
        {
            $best_word = $key;
            $best_word_count = $value;
        }
    }

    return $best_word;
}
