use strict;
use warnings;

# use LWP::Simple qw(get);
use LWP::Simple qw(get);
use HTML::TreeBuilder 5 -weak;
use Data::Dumper;
use Spreadsheet::WriteExcel;
BEGIN { unshift @INC, '.'; }
use SendEmail;

use Encode;
 
# use MIME::Lite;
# use Net::SMTP;

my %metro_map = (
  "Девяткино" => "Красная ветка",
  "Гражданский проспект" => "Красная ветка",
  "Академическая" => "Красная ветка",
  "Политехническая" => "Красная ветка",
  "Площадь Мужества" => "Красная ветка",
  "Лесная" => "Красная ветка",
  "Выборгская" => "Красная ветка",
  "Площадь Ленина" => "Красная ветка",
  "Чернышевская" => "Красная ветка",
  "Площадь Восстания" => "Красная ветка",
  "Владимирская" => "Красная ветка",
  "Пушкинская" => "Красная ветка",
  "Технологический институт" => "Красная ветка",
  "Технологический институт" => "Синяя ветка",
  "Балтийская" => "Красная ветка",
  "Нарвская" => "Красная ветка",
  "Кировский завод" => "Красная ветка",
  "Автово" => "Красная ветка",
  "Ленинский проспект" => "Красная ветка",
  "Проспект Ветеранов" => "Красная ветка",
  "Парнас" => "Синяя ветка",
  "Проспект Просвещения" => "Синяя ветка",
  "Озерки" => "Синяя ветка",
  "Удельная" => "Синяя ветка",
  "Пионерская" => "Синяя ветка",
  "Чёрная речка" => "Синяя ветка",
  "Петроградская" => "Синяя ветка",
  "Горьковская" => "Синяя ветка",
  "Невский проспект" => "Синяя ветка",
  "Сенная площадь" => "Синяя ветка",
  "Фрунзенская" => "Синяя ветка",
  "Московские ворота" => "Синяя ветка",
  "Электросила" => "Синяя ветка",
  "Парк Победы" => "Синяя ветка",
  "Московская" => "Синяя ветка",
  "Звёздная" => "Синяя ветка",
  "Купчино" => "Синяя ветка",
  "Беговая" => "Зеленая ветка",
  "Новокрестовская" => "Зеленая ветка",
  "Приморская" => "Зеленая ветка",
  "Василеостровская" => "Зеленая ветка",
  "Гостиный двор" => "Зеленая ветка",
  "Маяковская" => "Зеленая ветка",
  "Площадь Александра Невского" => "Зеленая ветка",
  "Елизаровская" => "Зеленая ветка",
  "Ломоносовская" => "Зеленая ветка",
  "Пролетарская" => "Зеленая ветка",
  "Рыбацкое" => "Зеленая ветка",
  "Спасская" => "Оранжевая ветка",
  "Достоевская" => "Оранжевая ветка",
  "Лиговский проспект" => "Оранжевая ветка",
  "Новочеркасская" => "Оранжевая ветка",
  "Ладожская" => "Оранжевая ветка",
  "Проспект Большевиков" => "Оранжевая ветка",
  "Улица Дыбенко" => "Оранжевая ветка",
  "Комендантский проспект" => "Фиолетовая ветка",
  "Старая Деревня" => "Фиолетовая ветка",
  "Крестовский остров" => "Фиолетовая ветка",
  "Чкаловская" => "Фиолетовая ветка",
  "Спортивная" => "Фиолетовая ветка",
  "Адмиралтейская" => "Фиолетовая ветка",
  "Садовая" => "Фиолетовая ветка",
  "Звенигородская" => "Фиолетовая ветка",
  "Обводный канал" => "Фиолетовая ветка",
  "Волковская" => "Фиолетовая ветка",
  "Бухарестская" => "Фиолетовая ветка",
  "Международная" => "Фиолетовая ветка",
);

my @metro_line = ('Красная ветка' , 'Синяя ветка' , 'Зеленая ветка' , 'Оранжевая ветка' , 'Фиолетовая ветка');

my $site = 'https://www.avito.ru';
my @metro1 = (
  "Новочеркасская"  ,
  "Ладожская"       ,
  "Площадь Ленина"  ,
  "Площадь Мужества",
  "Академическая"   ,
);

my @metro2 = (
  "Горьковская"     ,
  "Садовая"         ,
  "Сенная площадь"  ,
  "Спасская"        ,
  "Спортивная "     ,
  "Чкаловская"      ,
  "Горьковская"     ,
  "Садовая"         ,
  "Сенная площадь"  ,
  "Спортивная"      ,
  "Чкаловская"      ,
);

sub FoundElemInArray {
  my ( $elem , @arr ) = @_;
  my $count = 0 ;
  for (@arr) {
    if ($elem eq $_) {
      return $count;
    }
    $count++;
  }
}

# фунуция принимает данные и формирует execl файл
sub CreateExcel {
  my ($avito_data , $file , $metro ) = @_;
  # my @arr = @{$arr};
  my @metro_list = @{$metro};
  # print Dumper @metro_list;
  # Create a new Excel workbook
  my $workbook = Spreadsheet::WriteExcel->new($file);
   
  # Add a worksheet
  my $worksheet = $workbook->add_worksheet();
   
  #  Add and define a format
  my $format = $workbook->add_format(); # Add a format
  $format->set_bold();
  $format->set_color('red');
  $format->set_align('center');
   
  # Задаем титульник, за одно и хэш с нумерацией
  my ($row , $col) = (0 , 0);
  my %coord_hash_row = ();
  for my $m (@metro_line) {
    $coord_hash_row{$m} = 1;
    $worksheet->write($row, $col++, decode('utf8', $m));
  }
  # print Dumper %coord_hash_row;

  # пишем данные
  my $ret = 0;
  for my $a (@{$avito_data}) {
    my $link = $site.$a->{'link'};
    my $address = encode("UTF-8" , $a->{'address'});

    # записываем данные в таблицу
    for my $station (@metro_list) {
      # проверяем что метро находится в нашем списке
      if ($address =~ /$station/) {
        # проверяем что объявление сегодняшнее
        if ($ret = ProverkaLink($link)) {
          # write ( Y , X , text )
          # вычисляем в какой столбец положить запись
          my $X = FoundElemInArray($metro_map{$station} , @metro_line);
          # print "X: $station $X \n";
          # my $Y = $coord_hash_row{$metro_map{$station}};
          # print "Y: $metro_map{$station} $Y\n";
          $worksheet->write($coord_hash_row{$metro_map{$station}}++, $X , $link) if $ret == 1;
        } else {
          # если объявление не сегодня то оканчиваем работу, дальше объявления не имеет смысла читать
          return;
        }
        print $station."\n";
        sleep 2;
      }
    }
  }
}

# грабим данные в avito
sub GetContentAvito {
  my ($url) = @_;
  print "Обрабатывается URL: $url\n";
  my @arr;
  my $page = 1;
  while (1) {
    if ($page > 10) {
      return @arr;
    }
    my $html = get sprintf($url , $page);
    return @arr unless defined $html;
    my $tree = HTML::TreeBuilder->new;
    $tree->parse($html);

    # ищем все классы совпадающие с регурядкой, нужно из-за пробелов и других плохих символов
    for ($tree->look_down('class', qr/(?:.*description item_table-description.*)/)) {
      # это станция метро
      my $address = $_->look_down( 'class' , 'address');
      # это ссылка на квартиру
      my $link = $_->look_down( _tag => 'a' );
      print "Huy na rul" unless ($link->attr('href'));
      push (@arr , {'address' => $address->as_text , 'link' => $link->attr('href')});
    }
    print "Обработана страница $page\n";
    print "Всего записей получено ". scalar @arr ."\n";
    $page++;
    sleep 2;
  }
}

# провеяем что объявление выставлено сегодня
sub ProverkaLink {
  my ($url) = @_;
  print "проверяем URL $url\n";

  # тут сделан хитрый ход, чтобы избавиться от блокироовки по ip
  my $t = 1;
  my $data;
  while ($t) {
    my $html = get $url;
    return 0 unless defined $html;
    my $tree = HTML::TreeBuilder->new;
    $tree->parse($html);

    # получаем дату размещения объявления
    $data = $tree->look_down('class', "title-info-metadata-item");
    # print Dumper $data;
    return 2 unless $data;
    if ($data->as_text) {
      $t = 0;
    } else {
      print "попали на блокировку\n";
      sleep 60;
    }
  }

  $data = $data->as_text;
  $data= encode("UTF-8" , $data);
  if ($data =~ /сегодня/) {
    print $data."\n";
    return 1;
  } else {
    return 0;
  }
}


my $url_kvartiry = "https://www.avito.ru/sankt-peterburg/kvartiry/prodam?p=%s";
my $url_komnatu = "https://www.avito.ru/sankt-peterburg/komnaty/prodam?p=%s";
my $url_sdam_kvartiry = "https://www.avito.ru/sankt-peterburg/kvartiry/sdam?p=%s";

my @arr;
my $email = SendEmail->new('to' => '9543197@mail.ru');
@arr = GetContentAvito($url_kvartiry);
CreateExcel(\@arr , 'avito1_kvartira.xls', \@metro1 );
$email->set('attach' => 'avito1_kvartira.xls');
$email->send();
CreateExcel(\@arr , 'avito2_kvartira.xls', \@metro2 );
$email->set('attach' => 'avito2_kvartira.xls');
$email->send();
@arr = GetContentAvito($url_komnatu);
CreateExcel(\@arr , 'avito2_komnata.xls', \@metro2 );
$email->set('attach' => 'avito2_komnata.xls');
$email->send();

@arr = GetContentAvito($url_sdam_kvartiry);
CreateExcel(\@arr , 'avito2_sdam_kvartiry.xls', \@metro2 );
$email->set('attach' => 'avito2_sdam_kvartiry.xls');
$email->send();

exit 0;
