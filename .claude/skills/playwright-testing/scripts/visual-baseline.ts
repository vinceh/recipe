#!/usr/bin/env node
import * as fs from 'fs';
import * as path from 'path';
import { promisify } from 'util';
import { execSync } from 'child_process';
import * as crypto from 'crypto';

const readdir = promisify(fs.readdir);
const stat = promisify(fs.stat);
const copyFile = promisify(fs.copyFile);
const unlink = promisify(fs.unlink);
const rename = promisify(fs.rename);
const mkdir = promisify(fs.mkdir);
const readFile = promisify(fs.readFile);
const writeFile = promisify(fs.writeFile);

interface BaselineOptions {
  update?: boolean;
  compare?: boolean;
  clean?: boolean;
  list?: boolean;
  restore?: boolean;
  project?: string;
  path?: string;
}

/**
 * Manage visual regression test baselines
 */
class VisualBaselineManager {
  private baselineDir: string;
  private actualDir: string;
  private diffDir: string;
  private backupDir: string;
  private manifestPath: string;

  constructor(basePath: string = 'tests') {
    this.baselineDir = path.join(basePath, '__screenshots__');
    this.actualDir = path.join(basePath, '__screenshots-actual__');
    this.diffDir = path.join(basePath, '__screenshots-diff__');
    this.backupDir = path.join(basePath, '__screenshots-backup__');
    this.manifestPath = path.join(basePath, 'visual-baseline-manifest.json');
  }

  /**
   * Initialize directories
   */
  private async initDirectories(): Promise<void> {
    const dirs = [this.baselineDir, this.actualDir, this.diffDir, this.backupDir];
    for (const dir of dirs) {
      if (!fs.existsSync(dir)) {
        await mkdir(dir, { recursive: true });
      }
    }
  }

  /**
   * Get all screenshot files in a directory
   */
  private async getScreenshots(dir: string): Promise<string[]> {
    if (!fs.existsSync(dir)) {
      return [];
    }

    const files = await readdir(dir);
    return files.filter(file =>
      file.endsWith('.png') ||
      file.endsWith('.jpg') ||
      file.endsWith('.jpeg')
    );
  }

  /**
   * Calculate file hash for comparison
   */
  private async getFileHash(filePath: string): Promise<string> {
    const content = await readFile(filePath);
    return crypto.createHash('sha256').update(content).digest('hex');
  }

  /**
   * Load or create manifest
   */
  private async loadManifest(): Promise<any> {
    if (fs.existsSync(this.manifestPath)) {
      const content = await readFile(this.manifestPath, 'utf-8');
      return JSON.parse(content);
    }
    return {
      version: '1.0.0',
      created: new Date().toISOString(),
      baselines: {}
    };
  }

  /**
   * Save manifest
   */
  private async saveManifest(manifest: any): Promise<void> {
    await writeFile(this.manifestPath, JSON.stringify(manifest, null, 2));
  }

  /**
   * Update baselines from actual screenshots
   */
  async updateBaselines(options: BaselineOptions = {}): Promise<void> {
    console.log('📸 Updating Visual Baselines...\n');
    await this.initDirectories();

    const actualFiles = await this.getScreenshots(this.actualDir);
    if (actualFiles.length === 0) {
      console.log('⚠️ No actual screenshots found to update from.');
      console.log('   Run your visual tests first to generate screenshots.\n');
      return;
    }

    // Backup existing baselines
    const existingBaselines = await this.getScreenshots(this.baselineDir);
    if (existingBaselines.length > 0) {
      console.log('📦 Backing up existing baselines...');
      const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
      const backupSubDir = path.join(this.backupDir, timestamp);
      await mkdir(backupSubDir, { recursive: true });

      for (const file of existingBaselines) {
        const src = path.join(this.baselineDir, file);
        const dest = path.join(backupSubDir, file);
        await copyFile(src, dest);
      }
      console.log(`   ✓ Backed up ${existingBaselines.length} files to ${backupSubDir}\n`);
    }

    // Load manifest
    const manifest = await this.loadManifest();

    // Update baselines
    let updated = 0;
    let added = 0;
    for (const file of actualFiles) {
      const actualPath = path.join(this.actualDir, file);
      const baselinePath = path.join(this.baselineDir, file);

      const actualHash = await this.getFileHash(actualPath);
      const baselineExists = fs.existsSync(baselinePath);

      if (baselineExists) {
        const baselineHash = await this.getFileHash(baselinePath);
        if (actualHash !== baselineHash) {
          await copyFile(actualPath, baselinePath);
          console.log(`   ✓ Updated: ${file}`);
          updated++;
        } else {
          console.log(`   ⚬ Unchanged: ${file}`);
        }
      } else {
        await copyFile(actualPath, baselinePath);
        console.log(`   ✓ Added: ${file}`);
        added++;
      }

      // Update manifest
      const stats = await stat(actualPath);
      manifest.baselines[file] = {
        hash: actualHash,
        size: stats.size,
        updated: new Date().toISOString(),
        project: options.project || 'default'
      };
    }

    // Save manifest
    manifest.lastUpdated = new Date().toISOString();
    await saveManifest(manifest);

    console.log(`\n✅ Baseline Update Complete!`);
    console.log(`   📊 Summary:`);
    console.log(`   - ${added} new baselines added`);
    console.log(`   - ${updated} baselines updated`);
    console.log(`   - ${actualFiles.length - added - updated} unchanged`);
  }

  /**
   * Compare actual screenshots with baselines
   */
  async compareBaselines(options: BaselineOptions = {}): Promise<void> {
    console.log('🔍 Comparing Screenshots with Baselines...\n');
    await this.initDirectories();

    const actualFiles = await this.getScreenshots(this.actualDir);
    const baselineFiles = await this.getScreenshots(this.baselineDir);

    if (actualFiles.length === 0) {
      console.log('⚠️ No actual screenshots found to compare.');
      return;
    }

    if (baselineFiles.length === 0) {
      console.log('⚠️ No baseline screenshots found.');
      console.log('   Run with --update to create initial baselines.\n');
      return;
    }

    let matches = 0;
    let mismatches = 0;
    let missing = 0;

    // Check each actual screenshot
    for (const file of actualFiles) {
      const actualPath = path.join(this.actualDir, file);
      const baselinePath = path.join(this.baselineDir, file);

      if (!fs.existsSync(baselinePath)) {
        console.log(`   ❌ Missing baseline: ${file}`);
        missing++;
        continue;
      }

      const actualHash = await this.getFileHash(actualPath);
      const baselineHash = await this.getFileHash(baselinePath);

      if (actualHash === baselineHash) {
        console.log(`   ✓ Match: ${file}`);
        matches++;
      } else {
        console.log(`   ❌ Mismatch: ${file}`);
        mismatches++;

        // Generate diff if ImageMagick is available
        try {
          const diffPath = path.join(this.diffDir, `diff-${file}`);
          execSync(`compare "${baselinePath}" "${actualPath}" "${diffPath}" 2>/dev/null`, {
            stdio: 'ignore'
          });
          console.log(`      → Diff saved: ${diffPath}`);
        } catch {
          // ImageMagick not available, skip diff generation
        }
      }
    }

    // Check for removed screenshots
    const removed = baselineFiles.filter(file => !actualFiles.includes(file));
    if (removed.length > 0) {
      console.log('\n   ⚠️ Screenshots in baseline but not in actual:');
      removed.forEach(file => console.log(`      - ${file}`));
    }

    console.log(`\n📊 Comparison Results:`);
    console.log(`   ✓ Matches: ${matches}`);
    console.log(`   ❌ Mismatches: ${mismatches}`);
    console.log(`   ⚠️ Missing baselines: ${missing}`);
    console.log(`   ⚠️ Removed screenshots: ${removed.length}`);

    if (mismatches > 0 || missing > 0) {
      console.log('\n💡 To update baselines, run: npx tsx visual-baseline.ts --update');
      process.exit(1);
    }
  }

  /**
   * List all baselines
   */
  async listBaselines(): Promise<void> {
    console.log('📋 Visual Baselines:\n');

    const baselineFiles = await this.getScreenshots(this.baselineDir);
    if (baselineFiles.length === 0) {
      console.log('   No baselines found.\n');
      return;
    }

    const manifest = await this.loadManifest();

    console.log(`   Total: ${baselineFiles.length} baselines\n`);
    for (const file of baselineFiles) {
      const filePath = path.join(this.baselineDir, file);
      const stats = await stat(filePath);
      const info = manifest.baselines[file];

      console.log(`   📸 ${file}`);
      console.log(`      Size: ${(stats.size / 1024).toFixed(2)} KB`);
      if (info) {
        console.log(`      Updated: ${info.updated}`);
        console.log(`      Project: ${info.project || 'default'}`);
      }
      console.log();
    }
  }

  /**
   * Clean up temporary files
   */
  async clean(): Promise<void> {
    console.log('🧹 Cleaning temporary visual test files...\n');

    // Clean actual screenshots
    const actualFiles = await this.getScreenshots(this.actualDir);
    for (const file of actualFiles) {
      await unlink(path.join(this.actualDir, file));
    }
    console.log(`   ✓ Removed ${actualFiles.length} actual screenshots`);

    // Clean diff files
    const diffFiles = await this.getScreenshots(this.diffDir);
    for (const file of diffFiles) {
      await unlink(path.join(this.diffDir, file));
    }
    console.log(`   ✓ Removed ${diffFiles.length} diff files`);

    console.log('\n✅ Cleanup complete!');
  }

  /**
   * Restore baselines from backup
   */
  async restoreBaselines(timestamp?: string): Promise<void> {
    console.log('🔄 Restoring Baselines from Backup...\n');

    if (!fs.existsSync(this.backupDir)) {
      console.log('⚠️ No backups found.\n');
      return;
    }

    const backups = await readdir(this.backupDir);
    if (backups.length === 0) {
      console.log('⚠️ No backups found.\n');
      return;
    }

    // Select backup to restore
    let backupToRestore = timestamp;
    if (!backupToRestore) {
      // Use most recent backup
      backups.sort().reverse();
      backupToRestore = backups[0];
    }

    const backupPath = path.join(this.backupDir, backupToRestore);
    if (!fs.existsSync(backupPath)) {
      console.log(`❌ Backup not found: ${backupToRestore}\n`);
      console.log('Available backups:');
      backups.forEach(b => console.log(`   - ${b}`));
      return;
    }

    // Restore files
    const backupFiles = await readdir(backupPath);
    for (const file of backupFiles) {
      const src = path.join(backupPath, file);
      const dest = path.join(this.baselineDir, file);
      await copyFile(src, dest);
    }

    console.log(`✅ Restored ${backupFiles.length} baselines from ${backupToRestore}`);
  }
}

// Parse command line arguments and run
async function main() {
  const args = process.argv.slice(2);

  if (args.length === 0 || args.includes('--help') || args.includes('-h')) {
    console.log(`
Visual Baseline Manager for Playwright

Usage:
  npx tsx visual-baseline.ts [command] [options]

Commands:
  --update    Update baselines from actual screenshots
  --compare   Compare actual screenshots with baselines
  --list      List all current baselines
  --clean     Remove temporary screenshot files
  --restore   Restore baselines from backup

Options:
  --project   Project name for organizing baselines
  --path      Base path for screenshots (default: tests)
  --help      Show this help message

Examples:
  npx tsx visual-baseline.ts --update
  npx tsx visual-baseline.ts --compare
  npx tsx visual-baseline.ts --list
  npx tsx visual-baseline.ts --clean
  npx tsx visual-baseline.ts --restore

Visual Testing Workflow:
  1. Run visual tests: npm run test:visual
  2. Review screenshots: npx tsx visual-baseline.ts --compare
  3. Update baselines: npx tsx visual-baseline.ts --update
  4. Commit baselines to version control
`);
    process.exit(0);
  }

  // Parse options
  const options: BaselineOptions = {};
  args.forEach(arg => {
    const [key, value] = arg.split('=');
    const cleanKey = key.replace('--', '');

    switch (cleanKey) {
      case 'update':
        options.update = true;
        break;
      case 'compare':
        options.compare = true;
        break;
      case 'clean':
        options.clean = true;
        break;
      case 'list':
        options.list = true;
        break;
      case 'restore':
        options.restore = true;
        break;
      case 'project':
        options.project = value;
        break;
      case 'path':
        options.path = value;
        break;
    }
  });

  // Execute command
  const manager = new VisualBaselineManager(options.path);

  try {
    if (options.update) {
      await manager.updateBaselines(options);
    } else if (options.compare) {
      await manager.compareBaselines(options);
    } else if (options.list) {
      await manager.listBaselines();
    } else if (options.clean) {
      await manager.clean();
    } else if (options.restore) {
      await manager.restoreBaselines();
    } else {
      console.log('❌ No command specified. Use --help for usage information.');
      process.exit(1);
    }
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

// Run if called directly
if (require.main === module) {
  main();
}

export { VisualBaselineManager };