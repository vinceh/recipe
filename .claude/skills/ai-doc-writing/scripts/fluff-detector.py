#!/usr/bin/env python3
"""
AI Doc Fluff Detector

Detects common fluff patterns in markdown documentation that violate
AI-optimized documentation principles:
- No meta-commentary (dates, update indicators, explanations of changes)
- No conversational language
- No redundant restatements
- Proper heading hierarchy
- No transition phrases
- No status markers/emoji for emphasis
"""

import re
import sys
from pathlib import Path

class FluffDetector:
    def __init__(self):
        self.issues = []
        self.current_file = None
        self.current_line = 0

    # Meta-commentary patterns
    META_PATTERNS = {
        r'(?i)(last\s+updated|updated on|created on|modified on)': 'Meta-commentary: Date stamps',
        r'(?i)(!|UPDATED!|FIXED!|NEW!|IMPROVED!)': 'Status marker: Unnecessary emphasis',
        r'(?i)(we\s+(have\s+)?recently|we\s+(have\s+)?now|we\s+chose|we\s+added)': 'Meta-commentary: Change justification',
        r'(?i)(this\s+is\s+(now|currently)\s+fixed|critical\s+fix)': 'Status marker: Achievement callout',
        r'(?i)(✅|✓|🎉|⚠️|🔴)': 'Emoji: Unnecessary emphasis',
    }

    # Conversational patterns
    CONVERSATIONAL_PATTERNS = {
        r'(?i)(as\s+mentioned\s+(earlier|above|below)|see\s+examples?\s+(above|below))': 'Transition: Cross-reference',
        r'(?i)(for\s+those\s+who|if\s+you.*want\s+to|so\s+here\'?s)': 'Conversational: Informal setup',
        r'(?i)(you\'?ll?\s+want\s+to|you\s+should|you\s+need\s+to|you\s+can)': 'Imperative as second-person',
        r'(?i)(gotchas|heads?\s+up|questions\?|keep\s+this\s+in\s+mind)': 'Conversational: Informal tone',
        r'(?i)(tldr|quick\s+summary)': 'Conversational: Slang',
        r'(?i)(here\'?s\s+what\s+happens|this\s+is\s+how\s+it\s+works)': 'Narrative: Explanatory preamble',
    }

    # Redundancy patterns
    REDUNDANCY_PATTERNS = {
        r'(?i)(previously|before,|in\s+the\s+old|the\s+old\s+way)': 'Redundancy: Explaining what was changed',
        r'(?i)(that\s+approach\s+had|which\s+provides|this\s+design|the\s+main\s+benefit)': 'Redundancy: Justification',
        r'(?i)(don\'?t\s+do\s+this|not\s+recommended|avoid\s+this)': 'Redundancy: Restating after example',
    }

    # Hierarchy patterns
    HIERARCHY_PATTERN = r'^(#+)\s+'

    def detect(self, content: str, filename: str = 'stdin') -> list:
        """Detect fluff in markdown content."""
        self.issues = []
        self.current_file = filename
        lines = content.split('\n')

        # Check heading hierarchy
        self._check_heading_hierarchy(lines)

        # Check for fluff patterns
        for i, line in enumerate(lines, 1):
            self.current_line = i
            self._check_patterns(line)

        return self.issues

    def _check_heading_hierarchy(self, lines: list):
        """Verify heading hierarchy (no skipped levels like H1→H3)."""
        heading_levels = []
        for i, line in enumerate(lines, 1):
            match = re.match(self.HIERARCHY_PATTERN, line)
            if match:
                level = len(match.group(1))
                heading_levels.append((i, level))

        for i in range(1, len(heading_levels)):
            prev_level = heading_levels[i-1][1]
            curr_level = heading_levels[i][1]
            if curr_level > prev_level + 1:
                self.issues.append({
                    'line': heading_levels[i][0],
                    'type': 'Hierarchy: Skipped heading level',
                    'pattern': f'H{prev_level} → H{curr_level}',
                    'severity': 'warning'
                })

    def _check_patterns(self, line: str):
        """Check line against all fluff patterns."""
        # Skip code blocks and metadata
        if line.strip().startswith('```') or line.strip().startswith('---'):
            return

        # Check each pattern category
        self._check_pattern_group(line, self.META_PATTERNS, 'error')
        self._check_pattern_group(line, self.CONVERSATIONAL_PATTERNS, 'warning')
        self._check_pattern_group(line, self.REDUNDANCY_PATTERNS, 'warning')

    def _check_pattern_group(self, line: str, patterns: dict, severity: str):
        """Check line against a group of patterns."""
        for pattern, description in patterns.items():
            if re.search(pattern, line):
                self.issues.append({
                    'line': self.current_line,
                    'type': description.split(':')[0],
                    'pattern': description,
                    'severity': severity,
                    'content': line.strip()
                })

    def report(self, issues: list = None) -> str:
        """Generate a human-readable report."""
        if issues is None:
            issues = self.issues

        if not issues:
            return "✅ No fluff detected!"

        # Group by severity
        errors = [i for i in issues if i['severity'] == 'error']
        warnings = [i for i in issues if i['severity'] == 'warning']

        report = []
        if errors:
            report.append(f"❌ {len(errors)} ERROR(S):")
            for issue in errors:
                report.append(
                    f"  Line {issue['line']}: {issue['pattern']}"
                    f"\n    → {issue.get('content', '')[:60]}"
                )
        if warnings:
            report.append(f"⚠️  {len(warnings)} WARNING(S):")
            for issue in warnings:
                report.append(
                    f"  Line {issue['line']}: {issue['pattern']}"
                    f"\n    → {issue.get('content', '')[:60]}"
                )

        return '\n'.join(report)


def main():
    if len(sys.argv) < 2:
        print("Usage: fluff-detector.py <markdown-file> [...]")
        sys.exit(1)

    detector = FluffDetector()
    total_issues = 0

    for filepath in sys.argv[1:]:
        path = Path(filepath)
        if not path.exists():
            print(f"❌ File not found: {filepath}")
            continue

        content = path.read_text()
        issues = detector.detect(content, str(path))
        total_issues += len(issues)

        if issues:
            print(f"\n📄 {filepath}")
            print(detector.report(issues))
        else:
            print(f"\n✅ {filepath} - No fluff detected!")

    sys.exit(0 if total_issues == 0 else 1)


if __name__ == '__main__':
    main()
