/**
 * Phone number filter — strips phone numbers from text content.
 * Used in C2C messaging to prevent direct contact info exposure.
 *
 * Patterns matched:
 * - Algerian mobile: 05XXXXXXXX, 06XXXXXXXX, 07XXXXXXXX
 * - With country code: +213 XXXXXXXX, 00213 XXXXXXXX
 * - International formats: +XX XXX XXX XXXX
 * - Common separators: spaces, dots, dashes
 */
export function stripPhoneNumbers(content: string): string {
  // Algerian phone numbers (05/06/07 followed by 8 digits, with optional separators)
  const algerianPattern =
    /(?:\+?213|00213)?[\s.-]?0?[567][\s.-]?\d[\s.-]?\d[\s.-]?\d[\s.-]?\d[\s.-]?\d[\s.-]?\d[\s.-]?\d[\s.-]?\d/g;

  // Generic international numbers (+XX followed by 8-12 digits with separators)
  const internationalPattern =
    /\+\d{1,3}[\s.-]?\d[\s.-]?\d[\s.-]?\d[\s.-]?\d[\s.-]?\d[\s.-]?\d[\s.-]?\d[\s.-]?\d[\s.-]?\d{0,4}/g;

  // Sequence of 8+ digits (with optional separators)
  const rawDigitsPattern =
    /\b\d[\s.-]?\d[\s.-]?\d[\s.-]?\d[\s.-]?\d[\s.-]?\d[\s.-]?\d[\s.-]?\d[\s.-]?\d{0,4}\b/g;

  let filtered = content;
  filtered = filtered.replace(algerianPattern, '[numéro masqué / رقم مخفي]');
  filtered = filtered.replace(
    internationalPattern,
    '[numéro masqué / رقم مخفي]',
  );
  filtered = filtered.replace(rawDigitsPattern, '[numéro masqué / رقم مخفي]');

  return filtered;
}

/**
 * Checks if content contains any phone number patterns.
 */
export function containsPhoneNumber(content: string): boolean {
  return content !== stripPhoneNumbers(content);
}
