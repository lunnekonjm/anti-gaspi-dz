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
import { UserRole, OfferStatus, ExpiryType } from '../common/enums';

@Controller('api/v1/dev')
export class DevController {
  constructor(
    @InjectDataSource()
    private dataSource: DataSource,
    @InjectRepository(Offer)
    private offersRepository: Repository<Offer>,
    @InjectRepository(User)
    private usersRepository: Repository<User>,
  ) {}

  @Post('seed')
  async seed() {
    // Get or create a MERCHANT user to attach offers to
    let user = await this.usersRepository.findOne({
      where: { role: UserRole.MERCHANT },
    });
    if (!user) {
      user = this.usersRepository.create({
        phone_number: '+213000000000',
        role: UserRole.MERCHANT,
        display_name: 'Boulangerie Test',
      });
      await this.usersRepository.save(user);
    }

    const dummyOffers = Array.from({ length: 5 }).map((_, i) => {
      const offer = new Offer();
      offer.title = `Offre Dev Test ${i + 1}`;
      offer.initial_value = 1000;
      offer.sale_price = 300;
      offer.quantity_available = 5;
      offer.pickup_window_start = new Date(Date.now() + 3600000);
      offer.pickup_window_end = new Date(Date.now() + 7200000);
      offer.expiry_date = new Date(Date.now() + 86400000).toISOString();
      offer.expiry_type = ExpiryType.DLC;
      offer.status = OfferStatus.ACTIVE;
      offer.merchant_id = user.id;
      return offer;
    });

    await this.offersRepository.save(dummyOffers);
    return { success: true, message: '5 dummy offers seeded successfully' };
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
    return { success: true };
  }
}
