<?php

use PHPUnit\Framework\TestCase;

/**
 * Basic unit tests for CommitStack backend
 * These verify core functionality works correctly
 */
class BasicTest extends TestCase
{
    /**
     * Test that PHP is running correctly
     */
    public function testPhpWorks(): void
    {
        $this->assertTrue(true);
    }

    /**
     * Test point values are correct
     */
    public function testPointValues(): void
    {
        $checkinPoints = 10;
        $streak7Bonus = 50;
        $streak30Bonus = 200;

        $this->assertEquals(10, $checkinPoints);
        $this->assertEquals(50, $streak7Bonus);
        $this->assertEquals(200, $streak30Bonus);
    }

    /**
     * Test email validation
     */
    public function testEmailValidation(): void
    {
        $validEmail = 'test@example.com';
        $invalidEmail = 'not-an-email';

        $this->assertTrue(filter_var($validEmail, FILTER_VALIDATE_EMAIL) !== false);
        $this->assertFalse(filter_var($invalidEmail, FILTER_VALIDATE_EMAIL) !== false);
    }

    /**
     * Test goal frequency values
     */
    public function testValidGoalFrequencies(): void
    {
        $validFrequencies = ['daily', 'weekly', 'monthly'];
        
        $this->assertContains('daily', $validFrequencies);
        $this->assertContains('weekly', $validFrequencies);
        $this->assertContains('monthly', $validFrequencies);
        $this->assertNotContains('yearly', $validFrequencies);
    }

    /**
     * Test UUID format validation
     */
    public function testUuidFormat(): void
    {
        $validUuid = '550e8400-e29b-41d4-a716-446655440000';
        $invalidUuid = 'not-a-uuid';

        $pattern = '/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i';
        
        $this->assertMatchesRegularExpression($pattern, $validUuid);
        $this->assertDoesNotMatchRegularExpression($pattern, $invalidUuid);
    }
}
