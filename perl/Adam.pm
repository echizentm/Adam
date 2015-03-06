package Adam;
use strict;
use warnings;
use parent qw/Class::Accessor::Fast/;
use constant {
    DEFAULT_ALPHA  => 0.001,
    DEFAULT_BETA1  => 0.9,
    DEFAULT_BETA2  => 0.999,
    DEFAULT_ERROR  => 0.00000001,
    DEFAULT_LAMBDA => 0.99999999,

    POSITIVE_LABEL =>  1,
    NEGATIVE_LABEL => -1,
    MARGIN         =>  1,
};

__PACKAGE__->mk_accessors(qw/alpha/);
__PACKAGE__->mk_accessors(qw/beta1/);
__PACKAGE__->mk_accessors(qw/beta2/);
__PACKAGE__->mk_accessors(qw/error/);
__PACKAGE__->mk_accessors(qw/lambda/);

sub new {
    my ($class) = @_;
    return $class->SUPER::new({
        alpha   => DEFAULT_ALPHA,
        beta1   => DEFAULT_BETA1,
        beta2   => DEFAULT_BETA2,
        error   => DEFAULT_ERROR,
        lambda  => DEFAULT_LAMBDA,

        beta1_t => DEFAULT_BETA1,
        beta1_p => DEFAULT_BETA1,
        beta2_p => DEFAULT_BETA2,

        weight  => {},
        moment1 => {},
        moment2 => {},
    });
}

sub classify {
    my ($self, %args) = @_;
    return unless (__is_valid_data($args{data}));

    my $margin = 0.0;
    for my $feature (keys %{$args{data}}) {
        next unless ($self->{weight}{$feature});
        $margin += $self->{weight}{$feature} * $args{data}{$feature};
    }
    return $margin if ($args{as_margin});
    return ($margin > 0.0) ? POSITIVE_LABEL : NEGATIVE_LABEL;
}

sub update {
    my ($self, %args) = @_;
    return unless (__is_valid_label($args{label}));
    return unless (__is_valid_data($args{data}));

    return 1 if (($args{label} *
                  $self->classify(%args, as_margin => 1)
                 ) >= MARGIN);

    for my $feature (keys %{$args{data}}) {
        next if ($args{data}{$feature} == 0.0);
        my $gradient = -1.0 * $args{label} * $args{data}{$feature};

        $self->{moment1}{$feature} = 0.0 unless ($self->{moment1}{$feature});
        $self->{moment2}{$feature} = 0.0 unless ($self->{moment2}{$feature});

        $self->{moment1}{$feature} *= $self->{beta1_t};
        $self->{moment1}{$feature} += (1.0 - $self->{beta1_t}) * $gradient;
        $self->{moment2}{$feature} *= $self->{beta2};
        $self->{moment2}{$feature} += (1.0 - $self->{beta2}) * $gradient * $gradient;

        $self->{weight}{$feature} -= $self->{alpha}
                                   * sqrt(1.0 - $self->{beta2_p})
                                   / (1.0 - $self->{beta1_p})
                                   * $self->{moment1}{$feature}
                                   / (sqrt($self->{moment2}{$feature}) + $self->{error});
    }
    $self->{beta1_t} *= $self->{lambda};
    $self->{beta1_p} *= $self->{beta1};
    $self->{beta2_p} *= $self->{beta2};
    return 1
}

sub __is_valid_label {
    my ($label) = @_;

    return unless ($label);
    return (($label == POSITIVE_LABEL) or
            ($label == NEGATIVE_LABEL)
           ) ? 1 : 0;
}

sub __is_valid_data {
    my ($data) = @_;

    return unless ($data);
    return (ref($data) eq 'HASH') ? 1 : 0;
}

1;
