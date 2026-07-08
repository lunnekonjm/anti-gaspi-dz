import {
  Controller,
  Post,
  Delete,
  UseGuards,
  Headers,
  UnauthorizedException,
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

  private checkApiKey(apiKey: string) {
    const validKey = process.env.DEV_API_KEY || 'antigaspi_secret_dev_key';
    if (apiKey !== validKey) {
      throw new UnauthorizedException('Invalid Dev API Key');
    }
  }

  @Post('seed')
  async seed(@Headers('x-api-key') apiKey: string) {
    this.checkApiKey(apiKey);

    // Get the first MERCHANT user to attach offers to, or create one if none exists
    let user = await this.usersRepository.findOne({
      where: { role: UserRole.MERCHANT },
    });
    if (!user) {
      user = new User();
      user.phone_number = '+213000000000';
      user.role = UserRole.MERCHANT;
      user.business_name = 'Boulangerie Test';
      user.full_name = 'Dev Test Merchant';
      user.latitude = 36.7525;
      user.longitude = 3.04197;
      await this.usersRepository.save(user);
    }

    const dummyOffers = Array.from({ length: 5 }).map((_, i) => {
      const offer = new Offer();
      offer.title = `Offre Dev Test ${i + 1}`;
      offer.initial_value = 1000;
      offer.sale_price = 300;
      offer.quantity_available = 5;
      offer.pickup_window_start = new Date(Date.now() + 3600000); // in 1 hour
      offer.pickup_window_end = new Date(Date.now() + 7200000); // in 2 hours
      offer.expiry_date = new Date(Date.now() + 86400000).toISOString(); // tomorrow
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
  async wipe(@Headers('x-api-key') apiKey: string) {
    this.checkApiKey(apiKey);

    // Truncate tables except Users (to keep login valid)
    // Careful with foreign keys
    await this.dataSource.query('TRUNCATE TABLE reservations CASCADE');
    await this.dataSource.query('TRUNCATE TABLE offers CASCADE');
    await this.dataSource.query('TRUNCATE TABLE donations CASCADE');
    await this.dataSource.query(
      'TRUNCATE TABLE institutional_donations CASCADE',
    );
    return { success: true };
  }
}
