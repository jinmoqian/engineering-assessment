package database;
use strict;
use Text::CSV;

sub new(){
    my $pkg = shift;
    my $this = {
        ra_header => undef,
        ra_rows => [],
        rh_column => undef,
    };
    bless $this, $pkg;

    open my $fh, "<", 'Mobile_Food_Facility_Permit.csv' or die "Open file :" + $!;
    my $csv = Text::CSV->new ({ quote_char => '"' });
    while (my $row = $csv->getline ($fh)) {
        if($this->{ra_header}){
            if(scalar @$row != scalar @{$this->{ra_header}}){
                die "Column numbers not match";
            }
            push @{$this->{ra_rows}}, $row;
        }else{
            $this->{rh_column} = {};
            for(my $i=0; $i < scalar @$row; $i++){
                $this->{rh_column}->{$row->[$i]}=$i;
            }
            $this->{ra_header} = $row;
        }
    }
    close $fh;
    return $this;
}

sub find{
    my $this = shift;
    my $keyword = shift;
    if($keyword eq ''){
        return [];
    }
    my @keys = ('Applicant', 'Address', 'FoodItems');
    my @all = map {
        $this->to_hash($_);
    } grep {
        my $found;
        for my $key (@keys){
            if (-1 != index(lc($_->[ $this->{rh_column}->{$key} ]), lc($keyword))){
                $found = 1;
                last;
            }
        }
        $found;
    } @{$this->{ra_rows}};
    \@all;
};

sub random_one{
    my $this = shift;
    my $l = scalar @{$this->{ra_rows}};
    my $rr = $this->{ra_rows}->[ rand($l) ];
    return $this->to_hash($rr);
}
sub to_hash{
    my $this = shift;
    my $row = shift;
    my $h = {};
    for my $key (keys %{$this->{rh_column}}){
        $h->{$key} = $row->[ $this->{rh_column}->{$key} ];
    }
    return $h;
}
1;
