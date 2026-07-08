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
    // ─── 1. Utilisateurs réalistes ───
    const findOrCreate = async (phone: string, role: UserRole, name: string) => {
      let user = await this.usersRepository.findOne({ where: { phone_number: phone } });
      if (!user) {
        user = this.usersRepository.create({ phone_number: phone, role, display_name: name });
        await this.usersRepository.save(user);
      }
      return user;
    };

    const boulangerie = await findOrCreate('+213551234567', UserRole.MERCHANT, 'Boulangerie El Baraka — Bab El Oued');
    const patisserie = await findOrCreate('+213557654321', UserRole.MERCHANT, 'Pâtisserie Dziriya — Hydra');
    const superette = await findOrCreate('+213559876543', UserRole.MERCHANT, 'Superette Familia — Kouba');
    const amina = await findOrCreate('+213550112233', UserRole.CONSUMER, 'Amina Benali');
    const karim = await findOrCreate('+213550445566', UserRole.CONSUMER, 'Karim Medjdoub');
    const fatima = await findOrCreate('+213550778899', UserRole.CONSUMER, 'Fatima Zohra H.');
    const elIhsane = await findOrCreate('+213550334455', UserRole.ASSOCIATION, 'Association El Ihsane — Alger');
    const kafil = await findOrCreate('+213550667788', UserRole.ASSOCIATION, 'Kafil El Yatim — Blida');

    // ─── 2. B2C Paniers Surprise ───
    const offersData = [
      {
        title: 'Panier Viennoiseries du matin',
        initial_value: 1200, sale_price: 400, quantity_available: 3,
        expiry_type: ExpiryType.DLC, status: OfferStatus.ACTIVE,
        merchant_id: boulangerie.id,
      },
      {
        title: 'Lot de Pains Traditionnels (Khobz)',
        initial_value: 600, sale_price: 200, quantity_available: 8,
        expiry_type: ExpiryType.DDM, status: OfferStatus.ACTIVE,
        merchant_id: boulangerie.id,
      },
      {
        title: 'Assortiment Baklawa & Makroud',
        initial_value: 2500, sale_price: 900, quantity_available: 2,
        expiry_type: ExpiryType.DLC, status: OfferStatus.ACTIVE,
        merchant_id: patisserie.id,
      },
      {
        title: 'Panier Fruits & Légumes de Saison',
        initial_value: 1800, sale_price: 600, quantity_available: 4,
        expiry_type: ExpiryType.DDM, status: OfferStatus.ACTIVE,
        merchant_id: superette.id,
      },
      {
        title: 'Box Produits Laitiers Soummam',
        initial_value: 950, sale_price: 350, quantity_available: 6,
        expiry_type: ExpiryType.DLC, status: OfferStatus.ACTIVE,
        merchant_id: superette.id,
      },
      {
        title: 'Msemen & Crêpes (reste du petit-déj)',
        initial_value: 500, sale_price: 150, quantity_available: 5,
        expiry_type: ExpiryType.DLC, status: OfferStatus.ACTIVE,
        merchant_id: boulangerie.id,
      },
      {
        title: 'Gâteau Montécao — commande annulée',
        initial_value: 3000, sale_price: 1000, quantity_available: 1,
        expiry_type: ExpiryType.DLC, status: OfferStatus.ACTIVE,
        merchant_id: patisserie.id,
      },
      {
        title: 'Panier Épuisé — Croissants',
        initial_value: 700, sale_price: 250, quantity_available: 0,
        expiry_type: ExpiryType.DLC, status: OfferStatus.SOLD_OUT,
        merchant_id: boulangerie.id,
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

    // ─── 3. C2C Dons Famille ───
    const donationsData = [
      {
        title: 'Couscous fait maison — reste du vendredi',
        description: 'Il nous reste 2 grandes marmites de couscous au poulet du repas familial de vendredi. Tout est frais, préparé ce matin. Disponible jusqu\'à 18h.',
        neighborhood: 'Bab El Oued (Alger)', donor_id: fatima.id, status: DonationStatus.AVAILABLE,
      },
      {
        title: 'Figues fraîches du jardin de Blida',
        description: 'Récolte abondante cette saison. Figues bien mûres et sucrées. Environ 4 kg disponibles, venez avec vos sachets.',
        neighborhood: 'Blida (Blida)', donor_id: karim.id, status: DonationStatus.AVAILABLE,
      },
      {
        title: 'Kesra et Matloue — trop de pain !',
        description: 'J\'ai fait trop de galettes ce matin pour les voisins. 6 kesra et 4 matloue disponibles. Encore chaudes !',
        neighborhood: 'Hussein Dey (Alger)', donor_id: fatima.id, status: DonationStatus.AVAILABLE,
      },
      {
        title: 'Conserves et huile d\'olive',
        description: 'Déménagement prévu. Conserves (tomate, harissa, confiture), 2 bouteilles d\'huile d\'olive de Kabylie. Tout est valide, juste besoin de place.',
        neighborhood: 'Kouba (Alger)', donor_id: amina.id, status: DonationStatus.AVAILABLE,
      },
      {
        title: 'Bourek et Garantita — restes d\'un événement',
        description: 'Reste de la fête d\'hier : bourek aux crevettes, garantita, et salade méchouia. Le tout conditionné proprement.',
        neighborhood: 'Bir Mourad Raïs (Alger)', donor_id: karim.id, status: DonationStatus.AVAILABLE,
      },
      {
        title: 'Rechta algéroise — don déjà réservé',
        description: 'Rechta préparée pour un événement annulé. Un voisin a déjà réservé.',
        neighborhood: 'El Harrach (Alger)', donor_id: fatima.id, status: DonationStatus.RESERVED,
      },
      {
        title: 'Lait Candia + yaourts Soummam (DLC courte)',
        description: '4 bouteilles de lait UHT et 12 yaourts nature, date de péremption dans 2 jours.',
        neighborhood: 'Bab Ezzouar (Alger)', donor_id: amina.id, status: DonationStatus.RESERVED,
      },
    ];

    for (const data of donationsData) {
      await this.donationsRepository.save(this.donationsRepository.create(data));
    }

    // ─── 4. B2A Dons Institutionnels ───
    const instDonationsData = [
      {
        professional_id: boulangerie.id, association_id: elIhsane.id,
        description: '80 baguettes et 30 pains spéciaux (complet, seigle) invendus en fin de journée. Ramassage possible entre 19h30 et 20h30 devant la boulangerie.',
        estimated_quantity: '110 pièces (~25 kg)',
        status: InstitutionalDonationStatus.ANNOUNCED,
      },
      {
        professional_id: patisserie.id, association_id: elIhsane.id,
        description: 'Surplus de gâteaux orientaux (makroud, baklawa, samsa) suite à une commande de mariage annulée. Excellent état, tout emballé.',
        estimated_quantity: '45 pièces (~10 kg)',
        status: InstitutionalDonationStatus.ACCEPTED,
      },
      {
        professional_id: superette.id, association_id: kafil.id,
        description: 'Lot de produits frais proches de la DLC : fromage, yaourts, jus. Tous parfaitement consommables.',
        estimated_quantity: '3 cartons (~20 kg)',
        status: InstitutionalDonationStatus.TRANSFERRED,
      },
      {
        professional_id: boulangerie.id, association_id: kafil.id,
        description: 'Don hebdomadaire de pain du dimanche. 50 baguettes disponibles à partir de 18h.',
        estimated_quantity: '50 baguettes (~12 kg)',
        status: InstitutionalDonationStatus.COMPLETED,
      },
    ];

    for (const data of instDonationsData) {
      await this.instDonationsRepository.save(this.instDonationsRepository.create(data));
    }

    // ─── 5. Réservations (différents statuts) ───
    const activeOffers = offers.filter(o => o.status === OfferStatus.ACTIVE);
    if (activeOffers.length >= 3) {
      const reservationsData = [
        {
          offer_id: activeOffers[0].id, consumer_id: amina.id,
          status: ReservationStatus.PENDING_PAYMENT,
        },
        {
          offer_id: activeOffers[1].id, consumer_id: karim.id,
          status: ReservationStatus.CONFIRMED,
          payment_reference: 'SATIM-2026-07081423', qr_code_token: 'qr-token-abc123',
          confirmed_at: new Date(),
        },
        {
          offer_id: activeOffers[2].id, consumer_id: amina.id,
          status: ReservationStatus.PICKED_UP,
          payment_reference: 'BARIDIMOB-2026-07081205',
          confirmed_at: new Date(Date.now() - 3600000), picked_up_at: new Date(),
        },
      ];

      for (const data of reservationsData) {
        await this.reservationsRepository.save(this.reservationsRepository.create(data));
      }
    }

    return {
      success: true,
      message: 'Données de démonstration générées avec succès',
      summary: {
        utilisateurs: '8 (3 commerçants, 3 consommateurs, 2 associations)',
        paniers_surprise: `${offers.length} (7 actifs, 1 épuisé)`,
        dons_famille: `${donationsData.length} (5 disponibles, 2 réservés)`,
        dons_institutionnels: `${instDonationsData.length} (annoncé, accepté, transféré, complété)`,
        reservations: '3 (en attente, confirmée, récupérée)',
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
