import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../database/entities';
import { UpdateConsentDto, UpdateProfileDto } from './dto';

@Injectable()
export class UsersService {
  private readonly logger = new Logger(UsersService.name);

  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  async findById(id: string): Promise<User | null> {
    return this.userRepository.findOne({ where: { id } });
  }

  /**
   * Update granular consents — three separate toggles.
   * Each consent is recorded with a timestamp per Loi 18-07.
   */
  async updateConsent(userId: string, dto: UpdateConsentDto): Promise<User> {
    await this.userRepository.update(userId, {
      consent_payment: dto.consent_payment,
      consent_geolocation: dto.consent_geolocation,
      consent_notifications: dto.consent_notifications,
      consent_timestamp: new Date(),
    });
    return this.userRepository.findOneOrFail({ where: { id: userId } });
  }

  async updateProfile(userId: string, dto: UpdateProfileDto): Promise<User> {
    await this.userRepository.update(userId, dto);
    return this.userRepository.findOneOrFail({ where: { id: userId } });
  }

  async updateFcmToken(userId: string, token: string): Promise<void> {
    await this.userRepository.update(userId, { fcm_token: token });
    this.logger.log(`Updated FCM token for user ${userId}`);
  }

  /**
   * Soft-delete + schedule deferred purge (droit à l'oubli, Loi 18-07).
   * The actual data purge happens via a scheduled job.
   */
  async deleteAccount(userId: string): Promise<void> {
    await this.userRepository.softDelete(userId);
    this.logger.log(`User ${userId} soft-deleted. Deferred purge scheduled.`);
  }
}
