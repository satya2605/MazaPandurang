import { getSupabaseClient } from '../db/supabase.js';

export async function getDonationsInfo(req, res, next) {
  try {
    const client = getSupabaseClient();

    const { data, error } = await client
      .from('donations_info')
      .select('*')
      .eq('is_active', true)
      .maybeSingle();

    if (error || !data) {
      return res.json({
        id: 'DON-001',
        title: 'Support Maza Pandurang Seva',
        slogan: 'तुमचा छोटासा हातभार, वारीच्या मोठ्या सेवेसाठी.',
        description: 'Voluntary contribution towards app maintenance, Wari service mapping, and emergency assistance.',
        externalDonationUrl: 'https://example.com/donate',
        qrCodeUrl: null,
      });
    }

    return res.json({
      id: data.id,
      title: data.title,
      slogan: data.slogan,
      description: data.description,
      externalDonationUrl: data.external_donation_url,
      qrCodeUrl: data.qr_code_url,
    });
  } catch (err) {
    next(err);
  }
}
