import 'dart:math';

/// A placeholder example shown in the empty title/description fields of the
/// new-season sheet.
///
/// The examples rotate so the sheet feels fresh on every visit. Copy rules:
/// warm, plain, and unhurried (see `brand/BRAND.md`), and never anything
/// that smells of scoring, streaks, quotas, or guilt (principle 3).
class SeasonExample {
  const SeasonExample(this.title, this.description);

  final String title;
  final String description;
}

/// Forty season ideas from many walks of life.
///
/// Kept as a plain const list so it stays easy to review and extend, and so
/// tests can assert over every entry.
const List<SeasonExample> seasonExamples = [
  SeasonExample(
    'Build a Tiny PLC',
    'Learn embedded control by actually building one.',
  ),
  SeasonExample(
    'Paint with Watercolors',
    'Play with washes and see what shows up on paper.',
  ),
  SeasonExample(
    'Learn Italian',
    'Order a coffee, greet a neighbor, enjoy the sounds.',
  ),
  SeasonExample(
    'Morning Walks',
    'Wander the neighborhood and notice how it changes.',
  ),
  SeasonExample(
    'Cook Something New',
    'Pick a recipe that looks fun and give it a try.',
  ),
  SeasonExample(
    'Learn Guitar',
    'Strum a few chords and find songs you like.',
  ),
  SeasonExample(
    'Practice Small Talk',
    'Start one friendly conversation and see where it goes.',
  ),
  SeasonExample(
    'Read About Psychology',
    'Explore how minds work, starting with curiosity.',
  ),
  SeasonExample(
    'Grow Herbs on the Windowsill',
    'Basil, mint, thyme — snip and taste as they grow.',
  ),
  SeasonExample(
    'Take Film Photos',
    'Slow down and notice the light before each shot.',
  ),
  SeasonExample(
    'Keep a Sketchbook',
    'Draw for fun and let the pages fill up.',
  ),
  SeasonExample(
    'Try Pottery',
    'Center the clay, wobble, and enjoy the mess.',
  ),
  SeasonExample(
    'Build a Birdhouse',
    'Measure twice, saw once, hang it where birds pass.',
  ),
  SeasonExample(
    'Watch the Night Sky',
    'Learn a few constellations from your own backyard.',
  ),
  SeasonExample(
    'Bake Sourdough',
    'Feed a starter and get to know its moods.',
  ),
  SeasonExample(
    'Knit a Scarf',
    'One stitch at a time; dropped stitches are welcome.',
  ),
  SeasonExample(
    'Morning Pages',
    'Pour unfiltered thoughts onto paper before the day starts.',
  ),
  SeasonExample(
    'Learn Chess Openings',
    'Try a new opening and watch how the game bends.',
  ),
  SeasonExample(
    'Evening Stretches',
    'Unwind with a few quiet minutes on the floor.',
  ),
  SeasonExample(
    'Try Meditation',
    'Sit still, breathe, and notice what the mind does.',
  ),
  SeasonExample(
    'Explore Local History',
    'Find the oldest building on your street and its story.',
  ),
  SeasonExample(
    'Learn Calligraphy',
    'Slow strokes, inky fingers, beautiful letters.',
  ),
  SeasonExample(
    'Press Wildflowers',
    'Gather blooms on walks and keep them in a book.',
  ),
  SeasonExample(
    'Ferment Vegetables',
    'Salt, jar, wait — taste the sour magic in a week.',
  ),
  SeasonExample(
    'Hike a New Trail',
    'Find a path you have never walked and pack a snack.',
  ),
  SeasonExample(
    'Try Social Dancing',
    'Learn a basic step and laugh through the missteps.',
  ),
  SeasonExample(
    'Join a Choir',
    'Sing with others; no solos required.',
  ),
  SeasonExample(
    'Write Poems',
    'Short lines about ordinary days.',
  ),
  SeasonExample(
    'Grow Houseplants',
    'Learn what each one wants, one leaf at a time.',
  ),
  SeasonExample(
    'Volunteer Locally',
    'Spend a few hours helping where help is needed.',
  ),
  SeasonExample(
    'Learn to Whittle',
    'Carve a spoon from a branch, slowly.',
  ),
  SeasonExample(
    'Try Origami',
    'Fold paper cranes and line them up on the shelf.',
  ),
  SeasonExample(
    'Make Candles',
    'Melt wax, pick a scent, pour, and wait.',
  ),
  SeasonExample(
    'Learn to Juggle',
    'Three balls, many drops, eventual rhythm.',
  ),
  SeasonExample(
    'Repair Instead of Replace',
    'Fix one broken thing and learn how it worked.',
  ),
  SeasonExample(
    'Explore Tea',
    'Taste your way across green, oolong, and herbal.',
  ),
  SeasonExample(
    'Learn Basic First Aid',
    'Know what to do until help arrives.',
  ),
  SeasonExample(
    'Collect Family Stories',
    'Ask a relative for one story and write it down.',
  ),
  SeasonExample(
    'Try Birdwatching',
    'Learn five local birds by sight and song.',
  ),
  SeasonExample(
    'Build a Simple Website',
    'A small page about something you love.',
  ),
];

int _lastExampleIndex = -1;

/// Picks an example for one opening of the new-season sheet.
///
/// Never returns the same example twice in a row, so back-to-back visits
/// always feel different. The optional [random] exists so tests can pass a
/// seeded source.
SeasonExample randomSeasonExample([Random? random]) {
  final source = random ?? Random();
  var index = source.nextInt(seasonExamples.length);
  if (index == _lastExampleIndex) {
    index = (index + 1) % seasonExamples.length;
  }
  _lastExampleIndex = index;
  return seasonExamples[index];
}
