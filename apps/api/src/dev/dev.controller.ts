import {
  Controller,
  Post,
  Delete,
  HttpCode,
} from '@nestjs/common';
import { InjectDataSource, InjectRepository } from '@nestjs/typeorm';
import { DataSource, Repository } from 'typeorm';
import { Offer } from '../database/entities/offer.entity';
import { User } from '../database/entities/user.entity';
import { Donation } from '../database/entities/donation.entity';
import { InstitutionalDonation } from '../database/entities/institutional-donation.entity';
import { Reservation } from '../database/entities/reservation.entity';
import {
  UserRole,
  OfferStatus,
  ExpiryType,
  DonationStatus,
  InstitutionalDonationStatus,
  ReservationStatus,
} from '../common/enums';

@Controller('api/v1/dev')
export class DevController {
  constructor(
    @InjectDataSource()
    private dataSource: DataSource,
    @InjectRepository(Offer)
    private offersRepository: Repository<Offer>,
    @InjectRepository(User)
    private usersRepository: Repository<User>,
    @InjectRepository(Donation)
    private donationsRepository: Repository<Donation>,
    @InjectRepository(InstitutionalDonation)
    private instDonationsRepository: Repository<InstitutionalDonation>,
    @InjectRepository(Reservation)
    private reservationsRepository: Repository<Reservation>,
  ) {}

  @Post('seed')
  async seed() {
    // ─── 1. Create users for each role ───
    let merchant = await this.usersRepository.findOne({
      where: { role: UserRole.MERCHANT },
    });
    if (!merchant) {
      merchant = this.usersRepository.create({
        phone_number: '+213550000001',
        role: UserRole.MERCHANT,
        display_name: 'Boulangerie El Baraka',
      });
      await this.usersRepository.save(merchant);
    }

    let merchant2 = await this.usersRepository.findOne({
      where: { phone_number: '+213550000005' },
    });
    if (!merchant2) {
      merchant2 = this.usersRepository.create({
        phone_number: '+213550000005',
        role: UserRole.MERCHANT,
        display_name: 'Pâtisserie Dziriya',
      });
      await this.usersRepository.save(merchant2);
    }

    let consumer = await this.usersRepository.findOne({
      where: { phone_number: '+213550000002' },
    });
    if (!consumer) {
      consumer = this.usersRepository.create({
        phone_number: '+213550000002',
        role: UserRole.CONSUMER,
        display_name: 'Amina B.',
      });
      await this.usersRepository.save(consumer);
    }

    let association = await this.usersRepository.findOne({
      where: { role: UserRole.ASSOCIATION },
    });
    if (!association) {
      association = this.usersRepository.create({
        phone_number: '+213550000003',
        role: UserRole.ASSOCIATION,
        display_name: 'Association El Ihsane',
      });
      await this.usersRepository.save(association);
    }

    let donor = await this.usersRepository.findOne({
      where: { phone_number: '+213550000004' },
    });
    if (!donor) {
      donor = this.usersRepository.create({
        phone_number: '+213550000004',
        role: UserRole.CONSUMER,
        display_name: 'Karim M.',
      });
      await this.usersRepository.save(donor);
    }

    // ─── 2. B2C Offers (Surprise Bags) ───
    const offersData = [
      {
        title: 'Panier Surprise Viennoiseries',
        initial_value: 1200,
        sale_price: 400,
        quantity_available: 3,
        expiry_type: ExpiryType.DLC,
        status: OfferStatus.ACTIVE,
        merchant_id: merchant.id,
      },
      {
        title: 'Lot de Pains du Jour',
        initial_value: 800,
        sale_price: 250,
        quantity_available: 5,
        expiry_type: ExpiryType.DDM,
        status: OfferStatus.ACTIVE,
        merchant_id: merchant.id,
      },
      {
        title: 'Assortiment Pâtisseries Orientales',
        initial_value: 2500,
        sale_price: 800,
        quantity_available: 2,
        expiry_type: ExpiryType.DLC,
        status: OfferStatus.ACTIVE,
        merchant_id: merchant2.id,
      },
      {
        title: 'Panier Fruits & Légumes',
        initial_value: 1500,
        sale_price: 500,
        quantity_available: 4,
        expiry_type: ExpiryType.DDM,
        status: OfferStatus.ACTIVE,
        merchant_id: merchant.id,
      },
      {
        title: 'Box Produits Laitiers',
        initial_value: 900,
        sale_price: 300,
        quantity_available: 6,
        expiry_type: ExpiryType.DLC,
        status: OfferStatus.ACTIVE,
        merchant_id: merchant2.id,
      },
      {
        title: 'Panier Épuisé (exemple)',
        initial_value: 700,
        sale_price: 200,
        quantity_available: 0,
        expiry_type: ExpiryType.DLC,
        status: OfferStatus.SOLD_OUT,
        merchant_id: merchant.id,
      },
    ];

    const offers: Offer[] = [];
    for (const data of offersData) {
      const offer = new Offer();
      Object.assign(offer, data);
      offer.pickup_window_start = new Date(Date.now() + 3600000);
      offer.pickup_window_end = new Date(Date.now() + 7200000);
      offer.expiry_date = new Date(Date.now() + 86400000).toISOString();
      offers.push(offer);
    }
    await this.offersRepository.save(offers);

    // ─── 3. C2C Donations (Family Tab) ───
    const donationsData = [
      {
        title: 'Couscous fait maison (reste de fête)',
        description:
          'Il nous reste 3 grandes marmites de couscous du mariage de mon frère. Tout est frais, préparé hier soir. Venez récupérer avant 18h.',
        neighborhood: 'Bab El Oued (Alger)',
        donor_id: donor.id,
        status: DonationStatus.AVAILABLE,
      },
      {
        title: 'Fruits du jardin — figues et grenades',
        description:
          'Récolte abondante cette saison. Figues fraîches et grenades bien mûres. Quantité : environ 5 kg.',
        neighborhood: 'Bir Mourad Raïs (Alger)',
        donor_id: consumer.id,
        status: DonationStatus.AVAILABLE,
      },
      {
        title: 'Galettes de semoule (Kesra)',
        description:
          'J\'ai préparé trop de kesra ce matin. 4 galettes disponibles, encore chaudes.',
        neighborhood: 'Hussein Dey (Alger)',
        donor_id: donor.id,
        status: DonationStatus.AVAILABLE,
      },
      {
        title: 'Lait et yaourts (date courte)',
        description:
          'Lait UHT et yaourts nature, date de péremption dans 2 jours. 6 bouteilles + 12 yaourts.',
        neighborhood: 'El Harrach (Alger)',
        donor_id: consumer.id,
        status: DonationStatus.RESERVED,
      },
      {
        title: 'Plat de Rechta (don réservé)',
        description:
          'Rechta algéroise préparée pour un événement annulé. Don déjà réservé par un voisin.',
        neighborhood: 'Kouba (Alger)',
        donor_id: donor.id,
        status: DonationStatus.RESERVED,
      },
    ];

    for (const data of donationsData) {
      const donation = this.donationsRepository.create(data);
      await this.donationsRepository.save(donation);
    }

    // ─── 4. B2A Institutional Donations ───
    const instDonationsData = [
      {
        professional_id: merchant.id,
        association_id: association.id,
        description:
          '50 baguettes invendues + 20 pains spéciaux. Ramassage possible entre 19h et 20h.',
        estimated_quantity: '70 pièces (~15 kg)',
        status: InstitutionalDonationStatus.ANNOUNCED,
      },
      {
        professional_id: merchant2.id,
        association_id: association.id,
        description:
          'Surplus de gâteaux orientaux suite à commande annulée. Excellent état.',
        estimated_quantity: '30 pièces (~8 kg)',
        status: InstitutionalDonationStatus.ACCEPTED,
      },
      {
        professional_id: merchant.id,
        association_id: association.id,
        description:
          'Lot de sandwichs préparés pour un événement reporté. DLC demain.',
        estimated_quantity: '25 sandwichs (~12 kg)',
        status: InstitutionalDonationStatus.TRANSFERRED,
      },
    ];

    for (const data of instDonationsData) {
      const instDonation = this.instDonationsRepository.create(data);
      await this.instDonationsRepository.save(instDonation);
    }

    // ─── 5. Reservations (different statuses) ───
    const activeOffers = offers.filter(
      (o) => o.status === OfferStatus.ACTIVE,
    );
    if (activeOffers.length >= 3) {
      const reservationsData = [
        {
          offer_id: activeOffers[0].id,
          consumer_id: consumer.id,
          status: ReservationStatus.PENDING_PAYMENT,
        },
        {
          offer_id: activeOffers[1].id,
          consumer_id: consumer.id,
          status: ReservationStatus.CONFIRMED,
          payment_reference: 'MOCK-PAY-001',
          qr_code_token: 'mock-qr-token-abc123',
          confirmed_at: new Date(),
        },
        {
          offer_id: activeOffers[2].id,
          consumer_id: consumer.id,
          status: ReservationStatus.PICKED_UP,
          payment_reference: 'MOCK-PAY-002',
          confirmed_at: new Date(Date.now() - 3600000),
          picked_up_at: new Date(),
        },
      ];

      for (const data of reservationsData) {
        const reservation = this.reservationsRepository.create(data);
        await this.reservationsRepository.save(reservation);
      }
    }

    return {
      success: true,
      message: 'Comprehensive seed completed',
      summary: {
        users: '5 (merchant x2, consumer x2, association x1)',
        offers: `${offers.length} (active, sold_out)`,
        donations: `${donationsData.length} (available, reserved)`,
        institutional_donations: `${instDonationsData.length} (announced, accepted, transferred)`,
        reservations: '3 (pending, confirmed, picked_up)',
      },
    };
  }

  @Delete('wipe')
  @HttpCode(204)
  async wipe() {
    await this.dataSource.query('TRUNCATE TABLE reservations CASCADE');
    await this.dataSource.query('TRUNCATE TABLE offers CASCADE');
    await this.dataSource.query('TRUNCATE TABLE donations CASCADE');
    await this.dataSource.query(
      'TRUNCATE TABLE institutional_donations CASCADE',
    );
    await this.dataSource.query('TRUNCATE TABLE messages CASCADE');
    await this.dataSource.query('TRUNCATE TABLE reports CASCADE');
    await this.dataSource.query('TRUNCATE TABLE transfer_deeds CASCADE');
    return { success: true };
  }
}
