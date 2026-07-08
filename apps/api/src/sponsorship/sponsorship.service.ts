import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThanOrEqual } from 'typeorm';
import { SponsorCampaign } from '../database/entities';

@Injectable()
export class SponsorshipService {
  private readonly logger = new Logger(SponsorshipService.name);

  constructor(
    @InjectRepository(SponsorCampaign)
    private readonly campaignRepository: Repository<SponsorCampaign>,
  ) {}

  async create(data: Partial<SponsorCampaign>): Promise<SponsorCampaign> {
    const campaign = this.campaignRepository.create(data);
    return this.campaignRepository.save(campaign);
  }

  async findActive(): Promise<SponsorCampaign[]> {
    return this.campaignRepository.find({
      where: { active: true },
    });
  }

  async findById(id: string): Promise<SponsorCampaign | null> {
    return this.campaignRepository.findOne({ where: { id } });
  }

  async useSponsorship(campaignId: string): Promise<boolean> {
    const campaign = await this.campaignRepository.findOne({
      where: { id: campaignId },
    });

    if (
      !campaign ||
      !campaign.active ||
      campaign.sponsored_offers_count_used >=
        campaign.sponsored_offers_count_limit ||
      Number(campaign.budget_remaining) <= 0
    ) {
      return false;
    }

    campaign.sponsored_offers_count_used += 1;
    await this.campaignRepository.save(campaign);
    return true;
  }
}
