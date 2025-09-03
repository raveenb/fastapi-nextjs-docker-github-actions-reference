import { cn, formatDate, truncate, capitalize, slugify } from "./utils";

describe("utils", () => {
  describe("cn", () => {
    it("should merge class names correctly", () => {
      expect(cn("px-2 py-1", "text-sm")).toBe("px-2 py-1 text-sm");
    });

    it("should handle conditional classes", () => {
      expect(cn("px-2", false && "hidden", "text-sm")).toBe("px-2 text-sm");
    });

    it("should merge tailwind classes correctly", () => {
      expect(cn("px-2", "px-4")).toBe("px-4");
    });
  });

  describe("formatDate", () => {
    it("should format date correctly", () => {
      const date = new Date("2024-01-15");
      expect(formatDate(date)).toMatch(/January 15, 2024/);
    });
  });

  describe("truncate", () => {
    it("should truncate long strings", () => {
      expect(truncate("This is a long string", 10)).toBe("This is a ...");
    });

    it("should not truncate short strings", () => {
      expect(truncate("Short", 10)).toBe("Short");
    });
  });

  describe("capitalize", () => {
    it("should capitalize first letter", () => {
      expect(capitalize("hello")).toBe("Hello");
    });

    it("should handle all caps", () => {
      expect(capitalize("HELLO")).toBe("Hello");
    });
  });

  describe("slugify", () => {
    it("should create slug from string", () => {
      expect(slugify("Hello World!")).toBe("hello-world");
    });

    it("should handle special characters", () => {
      expect(slugify("Hello@World#123")).toBe("helloworld123");
    });
  });
});