class IranCity {
  const IranCity(this.name, this.province);
  final String name;
  final String province;

  String get label => province == name ? name : '$name — $province';
}

const iranCities = <IranCity>[
  IranCity('تهران', 'تهران'),
  IranCity('کرج', 'تهران'),
  IranCity('اسلامشهر', 'تهران'),
  IranCity('ری', 'تهران'),
  IranCity('پرند', 'تهران'),
  IranCity('ورامین', 'تهران'),
  IranCity('قم', 'تهران'),
  IranCity('شهریار', 'اصفهان'),
  IranCity('کاشان', 'اصفهان'),
  IranCity('نجف‌آباد', 'اصفهان'),
  IranCity('خومینی‌شهر', 'اصفهان'),
  IranCity('مشهدرضا', 'اصفهان'),
  IranCity('برخوار', 'اصفهان'),
  IranCity('نجف', 'اصفهان'),
  IranCity('مشهد', 'خراسان رضوی'),
  IranCity('سبزوار', 'خراسان رضوی'),
  IranCity('نیشابور', 'خراسان رضوی'),
  IranCity('تربت حیدریه', 'خراسان رضوی'),
  IranCity('کاشمر', 'خراسان رضوی'),
  IranCity('شیراز', 'فارس'),
  IranCity('مرودشت', 'فارس'),
  IranCity('جهرم', 'فارس'),
  IranCity('کازرون', 'فارس'),
  IranCity('فسا', 'فارس'),
  IranCity('لار', 'فارس'),
  IranCity('تبریز', 'آذربایجان شرقی'),
  IranCity('مرند', 'آذربایجان شرقی'),
  IranCity('مراغه', 'آذربایجان شرقی'),
  IranCity('بناب', 'آذربایجان شرقی'),
  IranCity('اهر', 'آذربایجان شرقی'),
  IranCity('ارومیه', 'آذربایجان شرقی'),
  IranCity('شبستر', 'آذربایجان شرقی'),
  IranCity('سراب', 'آذربایجان شرقی'),
  IranCity('اردبیل', 'آذربایجان شرقی'),
  IranCity('ارومیه', 'آذربایجان شرقی'),
  IranCity('ارومیه', 'آذربایجان شرقی'),
  IranCity('ارومیه', 'آذربایجان شرقی'),
  IranCity('ارومیه', 'آذربایجان شرقی'),
];
