import { Controller, Post, Delete, UseGuards, Headers, UnauthorizedException, HttpCode } from '@nestjs/common';
import { InjectDataSource, InjectRepository } from '@nestjs/typeorm';
import { DataSource, Repository } from 'typeorm';
import { Offer } from '../database/entities/offer.entity';
import { User } from '../database/entities/user.entity';

@Controller('dev')
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

    // Get the first B2C user to attach offers to
    const user = await this.usersRepository.findOne({ where: { role: 'b2c' } });
    if (!user) {
      throw new UnauthorizedException('No B2C user found to attach offers to');
    }

    const dummyOffers = Array.from({ length: 5 }).map((_, i) => {
      const offer = new Offer();
      offer.title = `Offre Dev Test ${i + 1}`;
      offer.initialValue = 1000;
      offer.saleValue = 300;
      offer.quantity = 5;
      offer.pickupStart = new Date(Date.now() + 3600000); // in 1 hour
      offer.pickupEnd = new Date(Date.now() + 7200000); // in 2 hours
      offer.expiryDate = new Date(Date.now() + 86400000); // tomorrow
      offer.expiryType = 'DLC';
      offer.status = 'active';
      offer.merchantId = user.id;
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
    await this.dataSource.query('TRUNCATE TABLE institutional_donations CASCADE');
    return { success: true };
  }
}
