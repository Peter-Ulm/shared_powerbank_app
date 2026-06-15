class FaqItem {
  const FaqItem(this.q, this.a);
  final String q;
  final String a;
}

List<FaqItem> faqItems(String locale) {
  if (locale == 'en') {
    return const [
      FaqItem('How do I rent a power bank?',
          'Scan the cabinet QR, choose quantity, pay with mobile money, and take the ejected bank.'),
      FaqItem('Where do I return it?',
          'Insert it into any MariJoy cabinet with a free slot. No PIN needed to return.'),
      FaqItem('What if a bank does not eject?',
          'You are refunded automatically for that bank.'),
    ];
  }
  return const [
    FaqItem('Nakodije benki?',
        'Skani QR ya cabinet, chagua idadi, lipa kwa simu, kisha chukua benki iliyotoka.'),
    FaqItem('Narudisha wapi?',
        'Iingize kwenye cabinet yoyote ya MariJoy yenye nafasi. Hakuna PIN ya kurudisha.'),
    FaqItem('Benki isipotoka?', 'Unarejeshewa pesa kiotomatiki kwa benki hiyo.'),
  ];
}
