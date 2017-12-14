
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 c0 10 00       	mov    $0x10c000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 70 e9 10 80       	mov    $0x8010e970,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 8a 3b 10 80       	mov    $0x80103b8a,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 d4 9c 10 	movl   $0x80109cd4,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 80 e9 10 80 	movl   $0x8010e980,(%esp)
80100049:	e8 58 57 00 00       	call   801057a6 <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 cc 30 11 80 7c 	movl   $0x8011307c,0x801130cc
80100055:	30 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 d0 30 11 80 7c 	movl   $0x8011307c,0x801130d0
8010005f:	30 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 b4 e9 10 80 	movl   $0x8010e9b4,-0xc(%ebp)
80100069:	eb 46                	jmp    801000b1 <binit+0x7d>
    b->next = bcache.head.next;
8010006b:	8b 15 d0 30 11 80    	mov    0x801130d0,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 50 7c 30 11 80 	movl   $0x8011307c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	83 c0 0c             	add    $0xc,%eax
80100087:	c7 44 24 04 db 9c 10 	movl   $0x80109cdb,0x4(%esp)
8010008e:	80 
8010008f:	89 04 24             	mov    %eax,(%esp)
80100092:	e8 d1 55 00 00       	call   80105668 <initsleeplock>
    bcache.head.next->prev = b;
80100097:	a1 d0 30 11 80       	mov    0x801130d0,%eax
8010009c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010009f:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a5:	a3 d0 30 11 80       	mov    %eax,0x801130d0

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000aa:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000b1:	81 7d f4 7c 30 11 80 	cmpl   $0x8011307c,-0xc(%ebp)
801000b8:	72 b1                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    initsleeplock(&b->lock, "buffer");
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ba:	c9                   	leave  
801000bb:	c3                   	ret    

801000bc <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000bc:	55                   	push   %ebp
801000bd:	89 e5                	mov    %esp,%ebp
801000bf:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000c2:	c7 04 24 80 e9 10 80 	movl   $0x8010e980,(%esp)
801000c9:	e8 f9 56 00 00       	call   801057c7 <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000ce:	a1 d0 30 11 80       	mov    0x801130d0,%eax
801000d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d6:	eb 50                	jmp    80100128 <bget+0x6c>
    if(b->dev == dev && b->blockno == blockno){
801000d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000db:	8b 40 04             	mov    0x4(%eax),%eax
801000de:	3b 45 08             	cmp    0x8(%ebp),%eax
801000e1:	75 3c                	jne    8010011f <bget+0x63>
801000e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e6:	8b 40 08             	mov    0x8(%eax),%eax
801000e9:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000ec:	75 31                	jne    8010011f <bget+0x63>
      b->refcnt++;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 40 4c             	mov    0x4c(%eax),%eax
801000f4:	8d 50 01             	lea    0x1(%eax),%edx
801000f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fa:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
801000fd:	c7 04 24 80 e9 10 80 	movl   $0x8010e980,(%esp)
80100104:	e8 28 57 00 00       	call   80105831 <release>
      acquiresleep(&b->lock);
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	83 c0 0c             	add    $0xc,%eax
8010010f:	89 04 24             	mov    %eax,(%esp)
80100112:	e8 8b 55 00 00       	call   801056a2 <acquiresleep>
      return b;
80100117:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011a:	e9 94 00 00 00       	jmp    801001b3 <bget+0xf7>
  struct buf *b;

  acquire(&bcache.lock);

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010011f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100122:	8b 40 54             	mov    0x54(%eax),%eax
80100125:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100128:	81 7d f4 7c 30 11 80 	cmpl   $0x8011307c,-0xc(%ebp)
8010012f:	75 a7                	jne    801000d8 <bget+0x1c>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100131:	a1 cc 30 11 80       	mov    0x801130cc,%eax
80100136:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100139:	eb 63                	jmp    8010019e <bget+0xe2>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010013b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010013e:	8b 40 4c             	mov    0x4c(%eax),%eax
80100141:	85 c0                	test   %eax,%eax
80100143:	75 50                	jne    80100195 <bget+0xd9>
80100145:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100148:	8b 00                	mov    (%eax),%eax
8010014a:	83 e0 04             	and    $0x4,%eax
8010014d:	85 c0                	test   %eax,%eax
8010014f:	75 44                	jne    80100195 <bget+0xd9>
      b->dev = dev;
80100151:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100154:	8b 55 08             	mov    0x8(%ebp),%edx
80100157:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 0c             	mov    0xc(%ebp),%edx
80100160:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
80100176:	c7 04 24 80 e9 10 80 	movl   $0x8010e980,(%esp)
8010017d:	e8 af 56 00 00       	call   80105831 <release>
      acquiresleep(&b->lock);
80100182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100185:	83 c0 0c             	add    $0xc,%eax
80100188:	89 04 24             	mov    %eax,(%esp)
8010018b:	e8 12 55 00 00       	call   801056a2 <acquiresleep>
      return b;
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	eb 1e                	jmp    801001b3 <bget+0xf7>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100198:	8b 40 50             	mov    0x50(%eax),%eax
8010019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019e:	81 7d f4 7c 30 11 80 	cmpl   $0x8011307c,-0xc(%ebp)
801001a5:	75 94                	jne    8010013b <bget+0x7f>
      release(&bcache.lock);
      acquiresleep(&b->lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	c7 04 24 e2 9c 10 80 	movl   $0x80109ce2,(%esp)
801001ae:	e8 a1 03 00 00       	call   80100554 <panic>
}
801001b3:	c9                   	leave  
801001b4:	c3                   	ret    

801001b5 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001b5:	55                   	push   %ebp
801001b6:	89 e5                	mov    %esp,%ebp
801001b8:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801001be:	89 44 24 04          	mov    %eax,0x4(%esp)
801001c2:	8b 45 08             	mov    0x8(%ebp),%eax
801001c5:	89 04 24             	mov    %eax,(%esp)
801001c8:	e8 ef fe ff ff       	call   801000bc <bget>
801001cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
801001d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d3:	8b 00                	mov    (%eax),%eax
801001d5:	83 e0 02             	and    $0x2,%eax
801001d8:	85 c0                	test   %eax,%eax
801001da:	75 0b                	jne    801001e7 <bread+0x32>
    iderw(b);
801001dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001df:	89 04 24             	mov    %eax,(%esp)
801001e2:	e8 aa 29 00 00       	call   80102b91 <iderw>
  }
  return b;
801001e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ea:	c9                   	leave  
801001eb:	c3                   	ret    

801001ec <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
801001ec:	55                   	push   %ebp
801001ed:	89 e5                	mov    %esp,%ebp
801001ef:	83 ec 18             	sub    $0x18,%esp
  if(!holdingsleep(&b->lock))
801001f2:	8b 45 08             	mov    0x8(%ebp),%eax
801001f5:	83 c0 0c             	add    $0xc,%eax
801001f8:	89 04 24             	mov    %eax,(%esp)
801001fb:	e8 3f 55 00 00       	call   8010573f <holdingsleep>
80100200:	85 c0                	test   %eax,%eax
80100202:	75 0c                	jne    80100210 <bwrite+0x24>
    panic("bwrite");
80100204:	c7 04 24 f3 9c 10 80 	movl   $0x80109cf3,(%esp)
8010020b:	e8 44 03 00 00       	call   80100554 <panic>
  b->flags |= B_DIRTY;
80100210:	8b 45 08             	mov    0x8(%ebp),%eax
80100213:	8b 00                	mov    (%eax),%eax
80100215:	83 c8 04             	or     $0x4,%eax
80100218:	89 c2                	mov    %eax,%edx
8010021a:	8b 45 08             	mov    0x8(%ebp),%eax
8010021d:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021f:	8b 45 08             	mov    0x8(%ebp),%eax
80100222:	89 04 24             	mov    %eax,(%esp)
80100225:	e8 67 29 00 00       	call   80102b91 <iderw>
}
8010022a:	c9                   	leave  
8010022b:	c3                   	ret    

8010022c <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022c:	55                   	push   %ebp
8010022d:	89 e5                	mov    %esp,%ebp
8010022f:	83 ec 18             	sub    $0x18,%esp
  if(!holdingsleep(&b->lock))
80100232:	8b 45 08             	mov    0x8(%ebp),%eax
80100235:	83 c0 0c             	add    $0xc,%eax
80100238:	89 04 24             	mov    %eax,(%esp)
8010023b:	e8 ff 54 00 00       	call   8010573f <holdingsleep>
80100240:	85 c0                	test   %eax,%eax
80100242:	75 0c                	jne    80100250 <brelse+0x24>
    panic("brelse");
80100244:	c7 04 24 fa 9c 10 80 	movl   $0x80109cfa,(%esp)
8010024b:	e8 04 03 00 00       	call   80100554 <panic>

  releasesleep(&b->lock);
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	83 c0 0c             	add    $0xc,%eax
80100256:	89 04 24             	mov    %eax,(%esp)
80100259:	e8 9f 54 00 00       	call   801056fd <releasesleep>

  acquire(&bcache.lock);
8010025e:	c7 04 24 80 e9 10 80 	movl   $0x8010e980,(%esp)
80100265:	e8 5d 55 00 00       	call   801057c7 <acquire>
  b->refcnt--;
8010026a:	8b 45 08             	mov    0x8(%ebp),%eax
8010026d:	8b 40 4c             	mov    0x4c(%eax),%eax
80100270:	8d 50 ff             	lea    -0x1(%eax),%edx
80100273:	8b 45 08             	mov    0x8(%ebp),%eax
80100276:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
80100279:	8b 45 08             	mov    0x8(%ebp),%eax
8010027c:	8b 40 4c             	mov    0x4c(%eax),%eax
8010027f:	85 c0                	test   %eax,%eax
80100281:	75 47                	jne    801002ca <brelse+0x9e>
    // no one is waiting for it.
    b->next->prev = b->prev;
80100283:	8b 45 08             	mov    0x8(%ebp),%eax
80100286:	8b 40 54             	mov    0x54(%eax),%eax
80100289:	8b 55 08             	mov    0x8(%ebp),%edx
8010028c:	8b 52 50             	mov    0x50(%edx),%edx
8010028f:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	8b 40 50             	mov    0x50(%eax),%eax
80100298:	8b 55 08             	mov    0x8(%ebp),%edx
8010029b:	8b 52 54             	mov    0x54(%edx),%edx
8010029e:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
801002a1:	8b 15 d0 30 11 80    	mov    0x801130d0,%edx
801002a7:	8b 45 08             	mov    0x8(%ebp),%eax
801002aa:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801002ad:	8b 45 08             	mov    0x8(%ebp),%eax
801002b0:	c7 40 50 7c 30 11 80 	movl   $0x8011307c,0x50(%eax)
    bcache.head.next->prev = b;
801002b7:	a1 d0 30 11 80       	mov    0x801130d0,%eax
801002bc:	8b 55 08             	mov    0x8(%ebp),%edx
801002bf:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801002c2:	8b 45 08             	mov    0x8(%ebp),%eax
801002c5:	a3 d0 30 11 80       	mov    %eax,0x801130d0
  }
  
  release(&bcache.lock);
801002ca:	c7 04 24 80 e9 10 80 	movl   $0x8010e980,(%esp)
801002d1:	e8 5b 55 00 00       	call   80105831 <release>
}
801002d6:	c9                   	leave  
801002d7:	c3                   	ret    

801002d8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002d8:	55                   	push   %ebp
801002d9:	89 e5                	mov    %esp,%ebp
801002db:	83 ec 14             	sub    $0x14,%esp
801002de:	8b 45 08             	mov    0x8(%ebp),%eax
801002e1:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801002e8:	89 c2                	mov    %eax,%edx
801002ea:	ec                   	in     (%dx),%al
801002eb:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002ee:	8a 45 ff             	mov    -0x1(%ebp),%al
}
801002f1:	c9                   	leave  
801002f2:	c3                   	ret    

801002f3 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f3:	55                   	push   %ebp
801002f4:	89 e5                	mov    %esp,%ebp
801002f6:	83 ec 08             	sub    $0x8,%esp
801002f9:	8b 45 08             	mov    0x8(%ebp),%eax
801002fc:	8b 55 0c             	mov    0xc(%ebp),%edx
801002ff:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80100303:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100306:	8a 45 f8             	mov    -0x8(%ebp),%al
80100309:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010030c:	ee                   	out    %al,(%dx)
}
8010030d:	c9                   	leave  
8010030e:	c3                   	ret    

8010030f <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010030f:	55                   	push   %ebp
80100310:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100312:	fa                   	cli    
}
80100313:	5d                   	pop    %ebp
80100314:	c3                   	ret    

80100315 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100315:	55                   	push   %ebp
80100316:	89 e5                	mov    %esp,%ebp
80100318:	56                   	push   %esi
80100319:	53                   	push   %ebx
8010031a:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010031d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100321:	74 1c                	je     8010033f <printint+0x2a>
80100323:	8b 45 08             	mov    0x8(%ebp),%eax
80100326:	c1 e8 1f             	shr    $0x1f,%eax
80100329:	0f b6 c0             	movzbl %al,%eax
8010032c:	89 45 10             	mov    %eax,0x10(%ebp)
8010032f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100333:	74 0a                	je     8010033f <printint+0x2a>
    x = -xx;
80100335:	8b 45 08             	mov    0x8(%ebp),%eax
80100338:	f7 d8                	neg    %eax
8010033a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010033d:	eb 06                	jmp    80100345 <printint+0x30>
  else
    x = xx;
8010033f:	8b 45 08             	mov    0x8(%ebp),%eax
80100342:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100345:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010034c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010034f:	8d 41 01             	lea    0x1(%ecx),%eax
80100352:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100355:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100358:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035b:	ba 00 00 00 00       	mov    $0x0,%edx
80100360:	f7 f3                	div    %ebx
80100362:	89 d0                	mov    %edx,%eax
80100364:	8a 80 08 b0 10 80    	mov    -0x7fef4ff8(%eax),%al
8010036a:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
8010036e:	8b 75 0c             	mov    0xc(%ebp),%esi
80100371:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100374:	ba 00 00 00 00       	mov    $0x0,%edx
80100379:	f7 f6                	div    %esi
8010037b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010037e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100382:	75 c8                	jne    8010034c <printint+0x37>

  if(sign)
80100384:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100388:	74 10                	je     8010039a <printint+0x85>
    buf[i++] = '-';
8010038a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038d:	8d 50 01             	lea    0x1(%eax),%edx
80100390:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100393:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
80100398:	eb 17                	jmp    801003b1 <printint+0x9c>
8010039a:	eb 15                	jmp    801003b1 <printint+0x9c>
    consputc(buf[i]);
8010039c:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a2:	01 d0                	add    %edx,%eax
801003a4:	8a 00                	mov    (%eax),%al
801003a6:	0f be c0             	movsbl %al,%eax
801003a9:	89 04 24             	mov    %eax,(%esp)
801003ac:	e8 b7 03 00 00       	call   80100768 <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801003b1:	ff 4d f4             	decl   -0xc(%ebp)
801003b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003b8:	79 e2                	jns    8010039c <printint+0x87>
    consputc(buf[i]);
}
801003ba:	83 c4 30             	add    $0x30,%esp
801003bd:	5b                   	pop    %ebx
801003be:	5e                   	pop    %esi
801003bf:	5d                   	pop    %ebp
801003c0:	c3                   	ret    

801003c1 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c1:	55                   	push   %ebp
801003c2:	89 e5                	mov    %esp,%ebp
801003c4:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003c7:	a1 14 d9 10 80       	mov    0x8010d914,%eax
801003cc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003cf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d3:	74 0c                	je     801003e1 <cprintf+0x20>
    acquire(&cons.lock);
801003d5:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
801003dc:	e8 e6 53 00 00       	call   801057c7 <acquire>

  if (fmt == 0)
801003e1:	8b 45 08             	mov    0x8(%ebp),%eax
801003e4:	85 c0                	test   %eax,%eax
801003e6:	75 0c                	jne    801003f4 <cprintf+0x33>
    panic("null fmt");
801003e8:	c7 04 24 01 9d 10 80 	movl   $0x80109d01,(%esp)
801003ef:	e8 60 01 00 00       	call   80100554 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003f4:	8d 45 0c             	lea    0xc(%ebp),%eax
801003f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100401:	e9 1b 01 00 00       	jmp    80100521 <cprintf+0x160>
    if(c != '%'){
80100406:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010040a:	74 10                	je     8010041c <cprintf+0x5b>
      consputc(c);
8010040c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010040f:	89 04 24             	mov    %eax,(%esp)
80100412:	e8 51 03 00 00       	call   80100768 <consputc>
      continue;
80100417:	e9 02 01 00 00       	jmp    8010051e <cprintf+0x15d>
    }
    c = fmt[++i] & 0xff;
8010041c:	8b 55 08             	mov    0x8(%ebp),%edx
8010041f:	ff 45 f4             	incl   -0xc(%ebp)
80100422:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100425:	01 d0                	add    %edx,%eax
80100427:	8a 00                	mov    (%eax),%al
80100429:	0f be c0             	movsbl %al,%eax
8010042c:	25 ff 00 00 00       	and    $0xff,%eax
80100431:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100434:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100438:	75 05                	jne    8010043f <cprintf+0x7e>
      break;
8010043a:	e9 01 01 00 00       	jmp    80100540 <cprintf+0x17f>
    switch(c){
8010043f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100442:	83 f8 70             	cmp    $0x70,%eax
80100445:	74 4f                	je     80100496 <cprintf+0xd5>
80100447:	83 f8 70             	cmp    $0x70,%eax
8010044a:	7f 13                	jg     8010045f <cprintf+0x9e>
8010044c:	83 f8 25             	cmp    $0x25,%eax
8010044f:	0f 84 a3 00 00 00    	je     801004f8 <cprintf+0x137>
80100455:	83 f8 64             	cmp    $0x64,%eax
80100458:	74 14                	je     8010046e <cprintf+0xad>
8010045a:	e9 a7 00 00 00       	jmp    80100506 <cprintf+0x145>
8010045f:	83 f8 73             	cmp    $0x73,%eax
80100462:	74 57                	je     801004bb <cprintf+0xfa>
80100464:	83 f8 78             	cmp    $0x78,%eax
80100467:	74 2d                	je     80100496 <cprintf+0xd5>
80100469:	e9 98 00 00 00       	jmp    80100506 <cprintf+0x145>
    case 'd':
      printint(*argp++, 10, 1);
8010046e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100471:	8d 50 04             	lea    0x4(%eax),%edx
80100474:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100477:	8b 00                	mov    (%eax),%eax
80100479:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80100480:	00 
80100481:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100488:	00 
80100489:	89 04 24             	mov    %eax,(%esp)
8010048c:	e8 84 fe ff ff       	call   80100315 <printint>
      break;
80100491:	e9 88 00 00 00       	jmp    8010051e <cprintf+0x15d>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100496:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100499:	8d 50 04             	lea    0x4(%eax),%edx
8010049c:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010049f:	8b 00                	mov    (%eax),%eax
801004a1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801004a8:	00 
801004a9:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
801004b0:	00 
801004b1:	89 04 24             	mov    %eax,(%esp)
801004b4:	e8 5c fe ff ff       	call   80100315 <printint>
      break;
801004b9:	eb 63                	jmp    8010051e <cprintf+0x15d>
    case 's':
      if((s = (char*)*argp++) == 0)
801004bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004be:	8d 50 04             	lea    0x4(%eax),%edx
801004c1:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c4:	8b 00                	mov    (%eax),%eax
801004c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004c9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004cd:	75 09                	jne    801004d8 <cprintf+0x117>
        s = "(null)";
801004cf:	c7 45 ec 0a 9d 10 80 	movl   $0x80109d0a,-0x14(%ebp)
      for(; *s; s++)
801004d6:	eb 15                	jmp    801004ed <cprintf+0x12c>
801004d8:	eb 13                	jmp    801004ed <cprintf+0x12c>
        consputc(*s);
801004da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004dd:	8a 00                	mov    (%eax),%al
801004df:	0f be c0             	movsbl %al,%eax
801004e2:	89 04 24             	mov    %eax,(%esp)
801004e5:	e8 7e 02 00 00       	call   80100768 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004ea:	ff 45 ec             	incl   -0x14(%ebp)
801004ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004f0:	8a 00                	mov    (%eax),%al
801004f2:	84 c0                	test   %al,%al
801004f4:	75 e4                	jne    801004da <cprintf+0x119>
        consputc(*s);
      break;
801004f6:	eb 26                	jmp    8010051e <cprintf+0x15d>
    case '%':
      consputc('%');
801004f8:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004ff:	e8 64 02 00 00       	call   80100768 <consputc>
      break;
80100504:	eb 18                	jmp    8010051e <cprintf+0x15d>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
80100506:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
8010050d:	e8 56 02 00 00       	call   80100768 <consputc>
      consputc(c);
80100512:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100515:	89 04 24             	mov    %eax,(%esp)
80100518:	e8 4b 02 00 00       	call   80100768 <consputc>
      break;
8010051d:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010051e:	ff 45 f4             	incl   -0xc(%ebp)
80100521:	8b 55 08             	mov    0x8(%ebp),%edx
80100524:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100527:	01 d0                	add    %edx,%eax
80100529:	8a 00                	mov    (%eax),%al
8010052b:	0f be c0             	movsbl %al,%eax
8010052e:	25 ff 00 00 00       	and    $0xff,%eax
80100533:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100536:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010053a:	0f 85 c6 fe ff ff    	jne    80100406 <cprintf+0x45>
      consputc(c);
      break;
    }
  }

  if(locking)
80100540:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100544:	74 0c                	je     80100552 <cprintf+0x191>
    release(&cons.lock);
80100546:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
8010054d:	e8 df 52 00 00       	call   80105831 <release>
}
80100552:	c9                   	leave  
80100553:	c3                   	ret    

80100554 <panic>:

void
panic(char *s)
{
80100554:	55                   	push   %ebp
80100555:	89 e5                	mov    %esp,%ebp
80100557:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];

  cli();
8010055a:	e8 b0 fd ff ff       	call   8010030f <cli>
  cons.locking = 0;
8010055f:	c7 05 14 d9 10 80 00 	movl   $0x0,0x8010d914
80100566:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
80100569:	e8 ef 2d 00 00       	call   8010335d <lapicid>
8010056e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100572:	c7 04 24 11 9d 10 80 	movl   $0x80109d11,(%esp)
80100579:	e8 43 fe ff ff       	call   801003c1 <cprintf>
  cprintf(s);
8010057e:	8b 45 08             	mov    0x8(%ebp),%eax
80100581:	89 04 24             	mov    %eax,(%esp)
80100584:	e8 38 fe ff ff       	call   801003c1 <cprintf>
  cprintf("\n");
80100589:	c7 04 24 25 9d 10 80 	movl   $0x80109d25,(%esp)
80100590:	e8 2c fe ff ff       	call   801003c1 <cprintf>
  getcallerpcs(&s, pcs);
80100595:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100598:	89 44 24 04          	mov    %eax,0x4(%esp)
8010059c:	8d 45 08             	lea    0x8(%ebp),%eax
8010059f:	89 04 24             	mov    %eax,(%esp)
801005a2:	e8 d7 52 00 00       	call   8010587e <getcallerpcs>
  for(i=0; i<10; i++)
801005a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005ae:	eb 1a                	jmp    801005ca <panic+0x76>
    cprintf(" %p", pcs[i]);
801005b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005b3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005bb:	c7 04 24 27 9d 10 80 	movl   $0x80109d27,(%esp)
801005c2:	e8 fa fd ff ff       	call   801003c1 <cprintf>
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005c7:	ff 45 f4             	incl   -0xc(%ebp)
801005ca:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005ce:	7e e0                	jle    801005b0 <panic+0x5c>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005d0:	c7 05 cc d8 10 80 01 	movl   $0x1,0x8010d8cc
801005d7:	00 00 00 
  for(;;)
    ;
801005da:	eb fe                	jmp    801005da <panic+0x86>

801005dc <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005dc:	55                   	push   %ebp
801005dd:	89 e5                	mov    %esp,%ebp
801005df:	83 ec 28             	sub    $0x28,%esp
  int pos;

  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005e2:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005e9:	00 
801005ea:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801005f1:	e8 fd fc ff ff       	call   801002f3 <outb>
  pos = inb(CRTPORT+1) << 8;
801005f6:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801005fd:	e8 d6 fc ff ff       	call   801002d8 <inb>
80100602:	0f b6 c0             	movzbl %al,%eax
80100605:	c1 e0 08             	shl    $0x8,%eax
80100608:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
8010060b:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100612:	00 
80100613:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010061a:	e8 d4 fc ff ff       	call   801002f3 <outb>
  pos |= inb(CRTPORT+1);
8010061f:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100626:	e8 ad fc ff ff       	call   801002d8 <inb>
8010062b:	0f b6 c0             	movzbl %al,%eax
8010062e:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100631:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100635:	75 1b                	jne    80100652 <cgaputc+0x76>
    pos += 80 - pos%80;
80100637:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010063a:	b9 50 00 00 00       	mov    $0x50,%ecx
8010063f:	99                   	cltd   
80100640:	f7 f9                	idiv   %ecx
80100642:	89 d0                	mov    %edx,%eax
80100644:	ba 50 00 00 00       	mov    $0x50,%edx
80100649:	29 c2                	sub    %eax,%edx
8010064b:	89 d0                	mov    %edx,%eax
8010064d:	01 45 f4             	add    %eax,-0xc(%ebp)
80100650:	eb 34                	jmp    80100686 <cgaputc+0xaa>
  else if(c == BACKSPACE){
80100652:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100659:	75 0b                	jne    80100666 <cgaputc+0x8a>
    if(pos > 0) --pos;
8010065b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010065f:	7e 25                	jle    80100686 <cgaputc+0xaa>
80100661:	ff 4d f4             	decl   -0xc(%ebp)
80100664:	eb 20                	jmp    80100686 <cgaputc+0xaa>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100666:	8b 0d 04 b0 10 80    	mov    0x8010b004,%ecx
8010066c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010066f:	8d 50 01             	lea    0x1(%eax),%edx
80100672:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100675:	01 c0                	add    %eax,%eax
80100677:	8d 14 01             	lea    (%ecx,%eax,1),%edx
8010067a:	8b 45 08             	mov    0x8(%ebp),%eax
8010067d:	0f b6 c0             	movzbl %al,%eax
80100680:	80 cc 07             	or     $0x7,%ah
80100683:	66 89 02             	mov    %ax,(%edx)

  if(pos < 0 || pos > 25*80)
80100686:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010068a:	78 09                	js     80100695 <cgaputc+0xb9>
8010068c:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
80100693:	7e 0c                	jle    801006a1 <cgaputc+0xc5>
    panic("pos under/overflow");
80100695:	c7 04 24 2b 9d 10 80 	movl   $0x80109d2b,(%esp)
8010069c:	e8 b3 fe ff ff       	call   80100554 <panic>

  if((pos/80) >= 24){  // Scroll up.
801006a1:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006a8:	7e 53                	jle    801006fd <cgaputc+0x121>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006aa:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801006af:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006b5:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801006ba:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006c1:	00 
801006c2:	89 54 24 04          	mov    %edx,0x4(%esp)
801006c6:	89 04 24             	mov    %eax,(%esp)
801006c9:	e8 25 54 00 00       	call   80105af3 <memmove>
    pos -= 80;
801006ce:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006d2:	b8 80 07 00 00       	mov    $0x780,%eax
801006d7:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006da:	01 c0                	add    %eax,%eax
801006dc:	8b 0d 04 b0 10 80    	mov    0x8010b004,%ecx
801006e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801006e5:	01 d2                	add    %edx,%edx
801006e7:	01 ca                	add    %ecx,%edx
801006e9:	89 44 24 08          	mov    %eax,0x8(%esp)
801006ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801006f4:	00 
801006f5:	89 14 24             	mov    %edx,(%esp)
801006f8:	e8 2d 53 00 00       	call   80105a2a <memset>
  }

  outb(CRTPORT, 14);
801006fd:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
80100704:	00 
80100705:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010070c:	e8 e2 fb ff ff       	call   801002f3 <outb>
  outb(CRTPORT+1, pos>>8);
80100711:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100714:	c1 f8 08             	sar    $0x8,%eax
80100717:	0f b6 c0             	movzbl %al,%eax
8010071a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010071e:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100725:	e8 c9 fb ff ff       	call   801002f3 <outb>
  outb(CRTPORT, 15);
8010072a:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100731:	00 
80100732:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100739:	e8 b5 fb ff ff       	call   801002f3 <outb>
  outb(CRTPORT+1, pos);
8010073e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100741:	0f b6 c0             	movzbl %al,%eax
80100744:	89 44 24 04          	mov    %eax,0x4(%esp)
80100748:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
8010074f:	e8 9f fb ff ff       	call   801002f3 <outb>
  crt[pos] = ' ' | 0x0700;
80100754:	8b 15 04 b0 10 80    	mov    0x8010b004,%edx
8010075a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010075d:	01 c0                	add    %eax,%eax
8010075f:	01 d0                	add    %edx,%eax
80100761:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100766:	c9                   	leave  
80100767:	c3                   	ret    

80100768 <consputc>:

void
consputc(int c)
{
80100768:	55                   	push   %ebp
80100769:	89 e5                	mov    %esp,%ebp
8010076b:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
8010076e:	a1 cc d8 10 80       	mov    0x8010d8cc,%eax
80100773:	85 c0                	test   %eax,%eax
80100775:	74 07                	je     8010077e <consputc+0x16>
    cli();
80100777:	e8 93 fb ff ff       	call   8010030f <cli>
    for(;;)
      ;
8010077c:	eb fe                	jmp    8010077c <consputc+0x14>
  }

  if(c == BACKSPACE){
8010077e:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100785:	75 26                	jne    801007ad <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100787:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010078e:	e8 c1 73 00 00       	call   80107b54 <uartputc>
80100793:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010079a:	e8 b5 73 00 00       	call   80107b54 <uartputc>
8010079f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007a6:	e8 a9 73 00 00       	call   80107b54 <uartputc>
801007ab:	eb 0b                	jmp    801007b8 <consputc+0x50>
  } else
    uartputc(c);
801007ad:	8b 45 08             	mov    0x8(%ebp),%eax
801007b0:	89 04 24             	mov    %eax,(%esp)
801007b3:	e8 9c 73 00 00       	call   80107b54 <uartputc>
  cgaputc(c);
801007b8:	8b 45 08             	mov    0x8(%ebp),%eax
801007bb:	89 04 24             	mov    %eax,(%esp)
801007be:	e8 19 fe ff ff       	call   801005dc <cgaputc>
}
801007c3:	c9                   	leave  
801007c4:	c3                   	ret    

801007c5 <copy_buf>:

#define C(x)  ((x)-'@')  // Control-x


void copy_buf(char *dst, char *src, int len)
{
801007c5:	55                   	push   %ebp
801007c6:	89 e5                	mov    %esp,%ebp
801007c8:	83 ec 10             	sub    $0x10,%esp
  int i;

  for (i = 0; i < len; i++) {
801007cb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801007d2:	eb 17                	jmp    801007eb <copy_buf+0x26>
    dst[i] = src[i];
801007d4:	8b 55 fc             	mov    -0x4(%ebp),%edx
801007d7:	8b 45 08             	mov    0x8(%ebp),%eax
801007da:	01 c2                	add    %eax,%edx
801007dc:	8b 4d fc             	mov    -0x4(%ebp),%ecx
801007df:	8b 45 0c             	mov    0xc(%ebp),%eax
801007e2:	01 c8                	add    %ecx,%eax
801007e4:	8a 00                	mov    (%eax),%al
801007e6:	88 02                	mov    %al,(%edx)

void copy_buf(char *dst, char *src, int len)
{
  int i;

  for (i = 0; i < len; i++) {
801007e8:	ff 45 fc             	incl   -0x4(%ebp)
801007eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801007ee:	3b 45 10             	cmp    0x10(%ebp),%eax
801007f1:	7c e1                	jl     801007d4 <copy_buf+0xf>
    dst[i] = src[i];
  }
}
801007f3:	c9                   	leave  
801007f4:	c3                   	ret    

801007f5 <consoleintr>:

void
consoleintr(int (*getc)(void))
{
801007f5:	55                   	push   %ebp
801007f6:	89 e5                	mov    %esp,%ebp
801007f8:	57                   	push   %edi
801007f9:	56                   	push   %esi
801007fa:	53                   	push   %ebx
801007fb:	83 ec 2c             	sub    $0x2c,%esp
  int c, doprocdump = 0, doconsoleswitch = 0;
801007fe:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100805:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

  acquire(&cons.lock);
8010080c:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80100813:	e8 af 4f 00 00       	call   801057c7 <acquire>
  while((c = getc()) >= 0){
80100818:	e9 eb 01 00 00       	jmp    80100a08 <consoleintr+0x213>
    switch(c){
8010081d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100820:	83 f8 14             	cmp    $0x14,%eax
80100823:	74 3b                	je     80100860 <consoleintr+0x6b>
80100825:	83 f8 14             	cmp    $0x14,%eax
80100828:	7f 13                	jg     8010083d <consoleintr+0x48>
8010082a:	83 f8 08             	cmp    $0x8,%eax
8010082d:	0f 84 16 01 00 00    	je     80100949 <consoleintr+0x154>
80100833:	83 f8 10             	cmp    $0x10,%eax
80100836:	74 1c                	je     80100854 <consoleintr+0x5f>
80100838:	e9 3c 01 00 00       	jmp    80100979 <consoleintr+0x184>
8010083d:	83 f8 15             	cmp    $0x15,%eax
80100840:	0f 84 db 00 00 00    	je     80100921 <consoleintr+0x12c>
80100846:	83 f8 7f             	cmp    $0x7f,%eax
80100849:	0f 84 fa 00 00 00    	je     80100949 <consoleintr+0x154>
8010084f:	e9 25 01 00 00       	jmp    80100979 <consoleintr+0x184>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      // cprintf("PID of myPROC is %d\n.", myproc()->pid);
      doprocdump = 1;
80100854:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
      break;
8010085b:	e9 a8 01 00 00       	jmp    80100a08 <consoleintr+0x213>
    case C('T'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      if (active+1 > MAX_VC){
80100860:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100865:	40                   	inc    %eax
80100866:	83 f8 04             	cmp    $0x4,%eax
80100869:	7e 23                	jle    8010088e <consoleintr+0x99>
        active = 1;
8010086b:	c7 05 00 b0 10 80 01 	movl   $0x1,0x8010b000
80100872:	00 00 00 
        input = buf1;
80100875:	ba e0 32 11 80       	mov    $0x801132e0,%edx
8010087a:	bb 60 d6 10 80       	mov    $0x8010d660,%ebx
8010087f:	b8 23 00 00 00       	mov    $0x23,%eax
80100884:	89 d7                	mov    %edx,%edi
80100886:	89 de                	mov    %ebx,%esi
80100888:	89 c1                	mov    %eax,%ecx
8010088a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
8010088c:	eb 6e                	jmp    801008fc <consoleintr+0x107>
      } else{
        active = active + 1;
8010088e:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100893:	40                   	inc    %eax
80100894:	a3 00 b0 10 80       	mov    %eax,0x8010b000
        if(active == 2){
80100899:	a1 00 b0 10 80       	mov    0x8010b000,%eax
8010089e:	83 f8 02             	cmp    $0x2,%eax
801008a1:	75 17                	jne    801008ba <consoleintr+0xc5>
          buf2 = input;
801008a3:	ba 00 d7 10 80       	mov    $0x8010d700,%edx
801008a8:	bb e0 32 11 80       	mov    $0x801132e0,%ebx
801008ad:	b8 23 00 00 00       	mov    $0x23,%eax
801008b2:	89 d7                	mov    %edx,%edi
801008b4:	89 de                	mov    %ebx,%esi
801008b6:	89 c1                	mov    %eax,%ecx
801008b8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        }
        if(active == 3){
801008ba:	a1 00 b0 10 80       	mov    0x8010b000,%eax
801008bf:	83 f8 03             	cmp    $0x3,%eax
801008c2:	75 17                	jne    801008db <consoleintr+0xe6>
          buf3 = input;
801008c4:	ba a0 d7 10 80       	mov    $0x8010d7a0,%edx
801008c9:	bb e0 32 11 80       	mov    $0x801132e0,%ebx
801008ce:	b8 23 00 00 00       	mov    $0x23,%eax
801008d3:	89 d7                	mov    %edx,%edi
801008d5:	89 de                	mov    %ebx,%esi
801008d7:	89 c1                	mov    %eax,%ecx
801008d9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        }
        if(active == 4){
801008db:	a1 00 b0 10 80       	mov    0x8010b000,%eax
801008e0:	83 f8 04             	cmp    $0x4,%eax
801008e3:	75 17                	jne    801008fc <consoleintr+0x107>
          buf4 = input;
801008e5:	ba 40 d8 10 80       	mov    $0x8010d840,%edx
801008ea:	bb e0 32 11 80       	mov    $0x801132e0,%ebx
801008ef:	b8 23 00 00 00       	mov    $0x23,%eax
801008f4:	89 d7                	mov    %edx,%edi
801008f6:	89 de                	mov    %ebx,%esi
801008f8:	89 c1                	mov    %eax,%ecx
801008fa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        }
      }
      doconsoleswitch = 1;
801008fc:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
      break;
80100903:	e9 00 01 00 00       	jmp    80100a08 <consoleintr+0x213>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100908:	a1 68 33 11 80       	mov    0x80113368,%eax
8010090d:	48                   	dec    %eax
8010090e:	a3 68 33 11 80       	mov    %eax,0x80113368
        consputc(BACKSPACE);
80100913:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010091a:	e8 49 fe ff ff       	call   80100768 <consputc>
8010091f:	eb 01                	jmp    80100922 <consoleintr+0x12d>
        }
      }
      doconsoleswitch = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100921:	90                   	nop
80100922:	8b 15 68 33 11 80    	mov    0x80113368,%edx
80100928:	a1 64 33 11 80       	mov    0x80113364,%eax
8010092d:	39 c2                	cmp    %eax,%edx
8010092f:	74 13                	je     80100944 <consoleintr+0x14f>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100931:	a1 68 33 11 80       	mov    0x80113368,%eax
80100936:	48                   	dec    %eax
80100937:	83 e0 7f             	and    $0x7f,%eax
8010093a:	8a 80 e0 32 11 80    	mov    -0x7feecd20(%eax),%al
        }
      }
      doconsoleswitch = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100940:	3c 0a                	cmp    $0xa,%al
80100942:	75 c4                	jne    80100908 <consoleintr+0x113>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100944:	e9 bf 00 00 00       	jmp    80100a08 <consoleintr+0x213>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100949:	8b 15 68 33 11 80    	mov    0x80113368,%edx
8010094f:	a1 64 33 11 80       	mov    0x80113364,%eax
80100954:	39 c2                	cmp    %eax,%edx
80100956:	74 1c                	je     80100974 <consoleintr+0x17f>
        input.e--;
80100958:	a1 68 33 11 80       	mov    0x80113368,%eax
8010095d:	48                   	dec    %eax
8010095e:	a3 68 33 11 80       	mov    %eax,0x80113368
        consputc(BACKSPACE);
80100963:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010096a:	e8 f9 fd ff ff       	call   80100768 <consputc>
      }
      break;
8010096f:	e9 94 00 00 00       	jmp    80100a08 <consoleintr+0x213>
80100974:	e9 8f 00 00 00       	jmp    80100a08 <consoleintr+0x213>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100979:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
8010097d:	0f 84 84 00 00 00    	je     80100a07 <consoleintr+0x212>
80100983:	8b 15 68 33 11 80    	mov    0x80113368,%edx
80100989:	a1 60 33 11 80       	mov    0x80113360,%eax
8010098e:	29 c2                	sub    %eax,%edx
80100990:	89 d0                	mov    %edx,%eax
80100992:	83 f8 7f             	cmp    $0x7f,%eax
80100995:	77 70                	ja     80100a07 <consoleintr+0x212>
        c = (c == '\r') ? '\n' : c;
80100997:	83 7d dc 0d          	cmpl   $0xd,-0x24(%ebp)
8010099b:	74 05                	je     801009a2 <consoleintr+0x1ad>
8010099d:	8b 45 dc             	mov    -0x24(%ebp),%eax
801009a0:	eb 05                	jmp    801009a7 <consoleintr+0x1b2>
801009a2:	b8 0a 00 00 00       	mov    $0xa,%eax
801009a7:	89 45 dc             	mov    %eax,-0x24(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801009aa:	a1 68 33 11 80       	mov    0x80113368,%eax
801009af:	8d 50 01             	lea    0x1(%eax),%edx
801009b2:	89 15 68 33 11 80    	mov    %edx,0x80113368
801009b8:	83 e0 7f             	and    $0x7f,%eax
801009bb:	89 c2                	mov    %eax,%edx
801009bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
801009c0:	88 82 e0 32 11 80    	mov    %al,-0x7feecd20(%edx)
        consputc(c);
801009c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801009c9:	89 04 24             	mov    %eax,(%esp)
801009cc:	e8 97 fd ff ff       	call   80100768 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801009d1:	83 7d dc 0a          	cmpl   $0xa,-0x24(%ebp)
801009d5:	74 18                	je     801009ef <consoleintr+0x1fa>
801009d7:	83 7d dc 04          	cmpl   $0x4,-0x24(%ebp)
801009db:	74 12                	je     801009ef <consoleintr+0x1fa>
801009dd:	a1 68 33 11 80       	mov    0x80113368,%eax
801009e2:	8b 15 60 33 11 80    	mov    0x80113360,%edx
801009e8:	83 ea 80             	sub    $0xffffff80,%edx
801009eb:	39 d0                	cmp    %edx,%eax
801009ed:	75 18                	jne    80100a07 <consoleintr+0x212>
          input.w = input.e;
801009ef:	a1 68 33 11 80       	mov    0x80113368,%eax
801009f4:	a3 64 33 11 80       	mov    %eax,0x80113364
          wakeup(&input.r);
801009f9:	c7 04 24 60 33 11 80 	movl   $0x80113360,(%esp)
80100a00:	e8 99 45 00 00       	call   80104f9e <wakeup>
        }
      }
      break;
80100a05:	eb 00                	jmp    80100a07 <consoleintr+0x212>
80100a07:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0, doconsoleswitch = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
80100a08:	8b 45 08             	mov    0x8(%ebp),%eax
80100a0b:	ff d0                	call   *%eax
80100a0d:	89 45 dc             	mov    %eax,-0x24(%ebp)
80100a10:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80100a14:	0f 89 03 fe ff ff    	jns    8010081d <consoleintr+0x28>
        }
      }
      break;
    }
  }
  release(&cons.lock);
80100a1a:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80100a21:	e8 0b 4e 00 00       	call   80105831 <release>
  if(doprocdump){
80100a26:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100a2a:	74 1d                	je     80100a49 <consoleintr+0x254>
    cprintf("aout to call procdump.\n");
80100a2c:	c7 04 24 3e 9d 10 80 	movl   $0x80109d3e,(%esp)
80100a33:	e8 89 f9 ff ff       	call   801003c1 <cprintf>
    procdump();  // now call procdump() wo. cons.lock held
80100a38:	e8 6b 46 00 00       	call   801050a8 <procdump>
    cprintf("after the call procdump.\n");
80100a3d:	c7 04 24 56 9d 10 80 	movl   $0x80109d56,(%esp)
80100a44:	e8 78 f9 ff ff       	call   801003c1 <cprintf>

  }
  if(doconsoleswitch){
80100a49:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100a4d:	74 15                	je     80100a64 <consoleintr+0x26f>
    cprintf("\nActive console now: %d\n", active);
80100a4f:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100a54:	89 44 24 04          	mov    %eax,0x4(%esp)
80100a58:	c7 04 24 70 9d 10 80 	movl   $0x80109d70,(%esp)
80100a5f:	e8 5d f9 ff ff       	call   801003c1 <cprintf>
  }
}
80100a64:	83 c4 2c             	add    $0x2c,%esp
80100a67:	5b                   	pop    %ebx
80100a68:	5e                   	pop    %esi
80100a69:	5f                   	pop    %edi
80100a6a:	5d                   	pop    %ebp
80100a6b:	c3                   	ret    

80100a6c <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100a6c:	55                   	push   %ebp
80100a6d:	89 e5                	mov    %esp,%ebp
80100a6f:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100a72:	8b 45 08             	mov    0x8(%ebp),%eax
80100a75:	89 04 24             	mov    %eax,(%esp)
80100a78:	e8 b4 11 00 00       	call   80101c31 <iunlock>
  target = n;
80100a7d:	8b 45 10             	mov    0x10(%ebp),%eax
80100a80:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a83:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80100a8a:	e8 38 4d 00 00       	call   801057c7 <acquire>
  while(n > 0){
80100a8f:	e9 b7 00 00 00       	jmp    80100b4b <consoleread+0xdf>
    while((input.r == input.w) || (active != ip->minor)){
80100a94:	eb 41                	jmp    80100ad7 <consoleread+0x6b>
      if(myproc()->killed){
80100a96:	e8 0c 3b 00 00       	call   801045a7 <myproc>
80100a9b:	8b 40 24             	mov    0x24(%eax),%eax
80100a9e:	85 c0                	test   %eax,%eax
80100aa0:	74 21                	je     80100ac3 <consoleread+0x57>
        release(&cons.lock);
80100aa2:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80100aa9:	e8 83 4d 00 00       	call   80105831 <release>
        ilock(ip);
80100aae:	8b 45 08             	mov    0x8(%ebp),%eax
80100ab1:	89 04 24             	mov    %eax,(%esp)
80100ab4:	e8 6e 10 00 00       	call   80101b27 <ilock>
        return -1;
80100ab9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100abe:	e9 b3 00 00 00       	jmp    80100b76 <consoleread+0x10a>
      }
      sleep(&input.r, &cons.lock);
80100ac3:	c7 44 24 04 e0 d8 10 	movl   $0x8010d8e0,0x4(%esp)
80100aca:	80 
80100acb:	c7 04 24 60 33 11 80 	movl   $0x80113360,(%esp)
80100ad2:	e8 f0 43 00 00       	call   80104ec7 <sleep>

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while((input.r == input.w) || (active != ip->minor)){
80100ad7:	8b 15 60 33 11 80    	mov    0x80113360,%edx
80100add:	a1 64 33 11 80       	mov    0x80113364,%eax
80100ae2:	39 c2                	cmp    %eax,%edx
80100ae4:	74 b0                	je     80100a96 <consoleread+0x2a>
80100ae6:	8b 45 08             	mov    0x8(%ebp),%eax
80100ae9:	8b 40 54             	mov    0x54(%eax),%eax
80100aec:	0f bf d0             	movswl %ax,%edx
80100aef:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100af4:	39 c2                	cmp    %eax,%edx
80100af6:	75 9e                	jne    80100a96 <consoleread+0x2a>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100af8:	a1 60 33 11 80       	mov    0x80113360,%eax
80100afd:	8d 50 01             	lea    0x1(%eax),%edx
80100b00:	89 15 60 33 11 80    	mov    %edx,0x80113360
80100b06:	83 e0 7f             	and    $0x7f,%eax
80100b09:	8a 80 e0 32 11 80    	mov    -0x7feecd20(%eax),%al
80100b0f:	0f be c0             	movsbl %al,%eax
80100b12:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100b15:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100b19:	75 17                	jne    80100b32 <consoleread+0xc6>
      if(n < target){
80100b1b:	8b 45 10             	mov    0x10(%ebp),%eax
80100b1e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100b21:	73 0d                	jae    80100b30 <consoleread+0xc4>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100b23:	a1 60 33 11 80       	mov    0x80113360,%eax
80100b28:	48                   	dec    %eax
80100b29:	a3 60 33 11 80       	mov    %eax,0x80113360
      }
      break;
80100b2e:	eb 25                	jmp    80100b55 <consoleread+0xe9>
80100b30:	eb 23                	jmp    80100b55 <consoleread+0xe9>
    }
    *dst++ = c;
80100b32:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b35:	8d 50 01             	lea    0x1(%eax),%edx
80100b38:	89 55 0c             	mov    %edx,0xc(%ebp)
80100b3b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100b3e:	88 10                	mov    %dl,(%eax)
    --n;
80100b40:	ff 4d 10             	decl   0x10(%ebp)
    if(c == '\n')
80100b43:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100b47:	75 02                	jne    80100b4b <consoleread+0xdf>
      break;
80100b49:	eb 0a                	jmp    80100b55 <consoleread+0xe9>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100b4b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100b4f:	0f 8f 3f ff ff ff    	jg     80100a94 <consoleread+0x28>
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&cons.lock);
80100b55:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80100b5c:	e8 d0 4c 00 00       	call   80105831 <release>
  ilock(ip);
80100b61:	8b 45 08             	mov    0x8(%ebp),%eax
80100b64:	89 04 24             	mov    %eax,(%esp)
80100b67:	e8 bb 0f 00 00       	call   80101b27 <ilock>

  return target - n;
80100b6c:	8b 45 10             	mov    0x10(%ebp),%eax
80100b6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b72:	29 c2                	sub    %eax,%edx
80100b74:	89 d0                	mov    %edx,%eax
}
80100b76:	c9                   	leave  
80100b77:	c3                   	ret    

80100b78 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100b78:	55                   	push   %ebp
80100b79:	89 e5                	mov    %esp,%ebp
80100b7b:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (active == ip->minor){
80100b7e:	8b 45 08             	mov    0x8(%ebp),%eax
80100b81:	8b 40 54             	mov    0x54(%eax),%eax
80100b84:	0f bf d0             	movswl %ax,%edx
80100b87:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100b8c:	39 c2                	cmp    %eax,%edx
80100b8e:	75 5a                	jne    80100bea <consolewrite+0x72>
    iunlock(ip);
80100b90:	8b 45 08             	mov    0x8(%ebp),%eax
80100b93:	89 04 24             	mov    %eax,(%esp)
80100b96:	e8 96 10 00 00       	call   80101c31 <iunlock>
    acquire(&cons.lock);
80100b9b:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80100ba2:	e8 20 4c 00 00       	call   801057c7 <acquire>
    for(i = 0; i < n; i++)
80100ba7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100bae:	eb 1b                	jmp    80100bcb <consolewrite+0x53>
      consputc(buf[i] & 0xff);
80100bb0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100bb3:	8b 45 0c             	mov    0xc(%ebp),%eax
80100bb6:	01 d0                	add    %edx,%eax
80100bb8:	8a 00                	mov    (%eax),%al
80100bba:	0f be c0             	movsbl %al,%eax
80100bbd:	0f b6 c0             	movzbl %al,%eax
80100bc0:	89 04 24             	mov    %eax,(%esp)
80100bc3:	e8 a0 fb ff ff       	call   80100768 <consputc>
  int i;

  if (active == ip->minor){
    iunlock(ip);
    acquire(&cons.lock);
    for(i = 0; i < n; i++)
80100bc8:	ff 45 f4             	incl   -0xc(%ebp)
80100bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100bce:	3b 45 10             	cmp    0x10(%ebp),%eax
80100bd1:	7c dd                	jl     80100bb0 <consolewrite+0x38>
      consputc(buf[i] & 0xff);
    release(&cons.lock);
80100bd3:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80100bda:	e8 52 4c 00 00       	call   80105831 <release>
    ilock(ip);
80100bdf:	8b 45 08             	mov    0x8(%ebp),%eax
80100be2:	89 04 24             	mov    %eax,(%esp)
80100be5:	e8 3d 0f 00 00       	call   80101b27 <ilock>
  }
  return n;
80100bea:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100bed:	c9                   	leave  
80100bee:	c3                   	ret    

80100bef <consoleinit>:

void
consoleinit(void)
{
80100bef:	55                   	push   %ebp
80100bf0:	89 e5                	mov    %esp,%ebp
80100bf2:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100bf5:	c7 44 24 04 89 9d 10 	movl   $0x80109d89,0x4(%esp)
80100bfc:	80 
80100bfd:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80100c04:	e8 9d 4b 00 00       	call   801057a6 <initlock>

  devsw[CONSOLE].write = consolewrite;
80100c09:	c7 05 cc 3e 11 80 78 	movl   $0x80100b78,0x80113ecc
80100c10:	0b 10 80 
  devsw[CONSOLE].read = consoleread;
80100c13:	c7 05 c8 3e 11 80 6c 	movl   $0x80100a6c,0x80113ec8
80100c1a:	0a 10 80 
  cons.locking = 1;
80100c1d:	c7 05 14 d9 10 80 01 	movl   $0x1,0x8010d914
80100c24:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100c27:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100c2e:	00 
80100c2f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100c36:	e8 08 21 00 00       	call   80102d43 <ioapicenable>
}
80100c3b:	c9                   	leave  
80100c3c:	c3                   	ret    
80100c3d:	00 00                	add    %al,(%eax)
	...

80100c40 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100c40:	55                   	push   %ebp
80100c41:	89 e5                	mov    %esp,%ebp
80100c43:	81 ec 38 01 00 00    	sub    $0x138,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100c49:	e8 59 39 00 00       	call   801045a7 <myproc>
80100c4e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100c51:	e8 51 2c 00 00       	call   801038a7 <begin_op>

  if((ip = namei(path)) == 0){
80100c56:	8b 45 08             	mov    0x8(%ebp),%eax
80100c59:	89 04 24             	mov    %eax,(%esp)
80100c5c:	e8 41 1b 00 00       	call   801027a2 <namei>
80100c61:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c64:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c68:	75 1b                	jne    80100c85 <exec+0x45>
    end_op();
80100c6a:	e8 ba 2c 00 00       	call   80103929 <end_op>
    cprintf("exec: fail\n");
80100c6f:	c7 04 24 91 9d 10 80 	movl   $0x80109d91,(%esp)
80100c76:	e8 46 f7 ff ff       	call   801003c1 <cprintf>
    return -1;
80100c7b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c80:	e9 f6 03 00 00       	jmp    8010107b <exec+0x43b>
  }
  ilock(ip);
80100c85:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c88:	89 04 24             	mov    %eax,(%esp)
80100c8b:	e8 97 0e 00 00       	call   80101b27 <ilock>
  pgdir = 0;
80100c90:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100c97:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100c9e:	00 
80100c9f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100ca6:	00 
80100ca7:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100cad:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cb1:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100cb4:	89 04 24             	mov    %eax,(%esp)
80100cb7:	e8 02 13 00 00       	call   80101fbe <readi>
80100cbc:	83 f8 34             	cmp    $0x34,%eax
80100cbf:	74 05                	je     80100cc6 <exec+0x86>
    goto bad;
80100cc1:	e9 89 03 00 00       	jmp    8010104f <exec+0x40f>
  if(elf.magic != ELF_MAGIC)
80100cc6:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100ccc:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100cd1:	74 05                	je     80100cd8 <exec+0x98>
    goto bad;
80100cd3:	e9 77 03 00 00       	jmp    8010104f <exec+0x40f>

  if((pgdir = setupkvm()) == 0)
80100cd8:	e8 59 7e 00 00       	call   80108b36 <setupkvm>
80100cdd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100ce0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100ce4:	75 05                	jne    80100ceb <exec+0xab>
    goto bad;
80100ce6:	e9 64 03 00 00       	jmp    8010104f <exec+0x40f>

  // Load program into memory.
  sz = 0;
80100ceb:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100cf2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100cf9:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100cff:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d02:	e9 fb 00 00 00       	jmp    80100e02 <exec+0x1c2>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100d07:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d0a:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100d11:	00 
80100d12:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d16:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100d1c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d20:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100d23:	89 04 24             	mov    %eax,(%esp)
80100d26:	e8 93 12 00 00       	call   80101fbe <readi>
80100d2b:	83 f8 20             	cmp    $0x20,%eax
80100d2e:	74 05                	je     80100d35 <exec+0xf5>
      goto bad;
80100d30:	e9 1a 03 00 00       	jmp    8010104f <exec+0x40f>
    if(ph.type != ELF_PROG_LOAD)
80100d35:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100d3b:	83 f8 01             	cmp    $0x1,%eax
80100d3e:	74 05                	je     80100d45 <exec+0x105>
      continue;
80100d40:	e9 b1 00 00 00       	jmp    80100df6 <exec+0x1b6>
    if(ph.memsz < ph.filesz)
80100d45:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100d4b:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100d51:	39 c2                	cmp    %eax,%edx
80100d53:	73 05                	jae    80100d5a <exec+0x11a>
      goto bad;
80100d55:	e9 f5 02 00 00       	jmp    8010104f <exec+0x40f>
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100d5a:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100d60:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100d66:	01 c2                	add    %eax,%edx
80100d68:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d6e:	39 c2                	cmp    %eax,%edx
80100d70:	73 05                	jae    80100d77 <exec+0x137>
      goto bad;
80100d72:	e9 d8 02 00 00       	jmp    8010104f <exec+0x40f>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100d77:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100d7d:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100d83:	01 d0                	add    %edx,%eax
80100d85:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d89:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d8c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d90:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d93:	89 04 24             	mov    %eax,(%esp)
80100d96:	e8 67 81 00 00       	call   80108f02 <allocuvm>
80100d9b:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d9e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100da2:	75 05                	jne    80100da9 <exec+0x169>
      goto bad;
80100da4:	e9 a6 02 00 00       	jmp    8010104f <exec+0x40f>
    if(ph.vaddr % PGSIZE != 0)
80100da9:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100daf:	25 ff 0f 00 00       	and    $0xfff,%eax
80100db4:	85 c0                	test   %eax,%eax
80100db6:	74 05                	je     80100dbd <exec+0x17d>
      goto bad;
80100db8:	e9 92 02 00 00       	jmp    8010104f <exec+0x40f>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100dbd:	8b 8d f8 fe ff ff    	mov    -0x108(%ebp),%ecx
80100dc3:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100dc9:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100dcf:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100dd3:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100dd7:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100dda:	89 54 24 08          	mov    %edx,0x8(%esp)
80100dde:	89 44 24 04          	mov    %eax,0x4(%esp)
80100de2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100de5:	89 04 24             	mov    %eax,(%esp)
80100de8:	e8 32 80 00 00       	call   80108e1f <loaduvm>
80100ded:	85 c0                	test   %eax,%eax
80100def:	79 05                	jns    80100df6 <exec+0x1b6>
      goto bad;
80100df1:	e9 59 02 00 00       	jmp    8010104f <exec+0x40f>
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100df6:	ff 45 ec             	incl   -0x14(%ebp)
80100df9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100dfc:	83 c0 20             	add    $0x20,%eax
80100dff:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100e02:	8b 85 34 ff ff ff    	mov    -0xcc(%ebp),%eax
80100e08:	0f b7 c0             	movzwl %ax,%eax
80100e0b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100e0e:	0f 8f f3 fe ff ff    	jg     80100d07 <exec+0xc7>
    if(ph.vaddr % PGSIZE != 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100e14:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100e17:	89 04 24             	mov    %eax,(%esp)
80100e1a:	e8 07 0f 00 00       	call   80101d26 <iunlockput>
  end_op();
80100e1f:	e8 05 2b 00 00       	call   80103929 <end_op>
  ip = 0;
80100e24:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100e2b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e2e:	05 ff 0f 00 00       	add    $0xfff,%eax
80100e33:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100e38:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100e3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e3e:	05 00 20 00 00       	add    $0x2000,%eax
80100e43:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e47:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e4a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e4e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e51:	89 04 24             	mov    %eax,(%esp)
80100e54:	e8 a9 80 00 00       	call   80108f02 <allocuvm>
80100e59:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100e5c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100e60:	75 05                	jne    80100e67 <exec+0x227>
    goto bad;
80100e62:	e9 e8 01 00 00       	jmp    8010104f <exec+0x40f>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100e67:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e6a:	2d 00 20 00 00       	sub    $0x2000,%eax
80100e6f:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e73:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e76:	89 04 24             	mov    %eax,(%esp)
80100e79:	e8 f4 82 00 00       	call   80109172 <clearpteu>
  sp = sz;
80100e7e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e81:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e84:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100e8b:	e9 95 00 00 00       	jmp    80100f25 <exec+0x2e5>
    if(argc >= MAXARG)
80100e90:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100e94:	76 05                	jbe    80100e9b <exec+0x25b>
      goto bad;
80100e96:	e9 b4 01 00 00       	jmp    8010104f <exec+0x40f>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100e9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e9e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ea5:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ea8:	01 d0                	add    %edx,%eax
80100eaa:	8b 00                	mov    (%eax),%eax
80100eac:	89 04 24             	mov    %eax,(%esp)
80100eaf:	e8 c9 4d 00 00       	call   80105c7d <strlen>
80100eb4:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100eb7:	29 c2                	sub    %eax,%edx
80100eb9:	89 d0                	mov    %edx,%eax
80100ebb:	48                   	dec    %eax
80100ebc:	83 e0 fc             	and    $0xfffffffc,%eax
80100ebf:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100ec2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ec5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ecc:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ecf:	01 d0                	add    %edx,%eax
80100ed1:	8b 00                	mov    (%eax),%eax
80100ed3:	89 04 24             	mov    %eax,(%esp)
80100ed6:	e8 a2 4d 00 00       	call   80105c7d <strlen>
80100edb:	40                   	inc    %eax
80100edc:	89 c2                	mov    %eax,%edx
80100ede:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ee1:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100ee8:	8b 45 0c             	mov    0xc(%ebp),%eax
80100eeb:	01 c8                	add    %ecx,%eax
80100eed:	8b 00                	mov    (%eax),%eax
80100eef:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100ef3:	89 44 24 08          	mov    %eax,0x8(%esp)
80100ef7:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100efa:	89 44 24 04          	mov    %eax,0x4(%esp)
80100efe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f01:	89 04 24             	mov    %eax,(%esp)
80100f04:	e8 21 84 00 00       	call   8010932a <copyout>
80100f09:	85 c0                	test   %eax,%eax
80100f0b:	79 05                	jns    80100f12 <exec+0x2d2>
      goto bad;
80100f0d:	e9 3d 01 00 00       	jmp    8010104f <exec+0x40f>
    ustack[3+argc] = sp;
80100f12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f15:	8d 50 03             	lea    0x3(%eax),%edx
80100f18:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f1b:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100f22:	ff 45 e4             	incl   -0x1c(%ebp)
80100f25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f28:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f32:	01 d0                	add    %edx,%eax
80100f34:	8b 00                	mov    (%eax),%eax
80100f36:	85 c0                	test   %eax,%eax
80100f38:	0f 85 52 ff ff ff    	jne    80100e90 <exec+0x250>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100f3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f41:	83 c0 03             	add    $0x3,%eax
80100f44:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100f4b:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100f4f:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100f56:	ff ff ff 
  ustack[1] = argc;
80100f59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f5c:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100f62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f65:	40                   	inc    %eax
80100f66:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f6d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f70:	29 d0                	sub    %edx,%eax
80100f72:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100f78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f7b:	83 c0 04             	add    $0x4,%eax
80100f7e:	c1 e0 02             	shl    $0x2,%eax
80100f81:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100f84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f87:	83 c0 04             	add    $0x4,%eax
80100f8a:	c1 e0 02             	shl    $0x2,%eax
80100f8d:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100f91:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100f97:	89 44 24 08          	mov    %eax,0x8(%esp)
80100f9b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f9e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100fa2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100fa5:	89 04 24             	mov    %eax,(%esp)
80100fa8:	e8 7d 83 00 00       	call   8010932a <copyout>
80100fad:	85 c0                	test   %eax,%eax
80100faf:	79 05                	jns    80100fb6 <exec+0x376>
    goto bad;
80100fb1:	e9 99 00 00 00       	jmp    8010104f <exec+0x40f>

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100fb6:	8b 45 08             	mov    0x8(%ebp),%eax
80100fb9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fbf:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100fc2:	eb 13                	jmp    80100fd7 <exec+0x397>
    if(*s == '/')
80100fc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fc7:	8a 00                	mov    (%eax),%al
80100fc9:	3c 2f                	cmp    $0x2f,%al
80100fcb:	75 07                	jne    80100fd4 <exec+0x394>
      last = s+1;
80100fcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fd0:	40                   	inc    %eax
80100fd1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100fd4:	ff 45 f4             	incl   -0xc(%ebp)
80100fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fda:	8a 00                	mov    (%eax),%al
80100fdc:	84 c0                	test   %al,%al
80100fde:	75 e4                	jne    80100fc4 <exec+0x384>
    if(*s == '/')
      last = s+1;
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100fe0:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fe3:	8d 50 6c             	lea    0x6c(%eax),%edx
80100fe6:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100fed:	00 
80100fee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100ff1:	89 44 24 04          	mov    %eax,0x4(%esp)
80100ff5:	89 14 24             	mov    %edx,(%esp)
80100ff8:	e8 39 4c 00 00       	call   80105c36 <safestrcpy>

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100ffd:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101000:	8b 40 04             	mov    0x4(%eax),%eax
80101003:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80101006:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101009:	8b 55 d4             	mov    -0x2c(%ebp),%edx
8010100c:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
8010100f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101012:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101015:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80101017:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010101a:	8b 40 18             	mov    0x18(%eax),%eax
8010101d:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80101023:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80101026:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101029:	8b 40 18             	mov    0x18(%eax),%eax
8010102c:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010102f:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80101032:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101035:	89 04 24             	mov    %eax,(%esp)
80101038:	e8 d3 7b 00 00       	call   80108c10 <switchuvm>
  freevm(oldpgdir);
8010103d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101040:	89 04 24             	mov    %eax,(%esp)
80101043:	e8 94 80 00 00       	call   801090dc <freevm>
  return 0;
80101048:	b8 00 00 00 00       	mov    $0x0,%eax
8010104d:	eb 2c                	jmp    8010107b <exec+0x43b>

 bad:
  if(pgdir)
8010104f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80101053:	74 0b                	je     80101060 <exec+0x420>
    freevm(pgdir);
80101055:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101058:	89 04 24             	mov    %eax,(%esp)
8010105b:	e8 7c 80 00 00       	call   801090dc <freevm>
  if(ip){
80101060:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80101064:	74 10                	je     80101076 <exec+0x436>
    iunlockput(ip);
80101066:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101069:	89 04 24             	mov    %eax,(%esp)
8010106c:	e8 b5 0c 00 00       	call   80101d26 <iunlockput>
    end_op();
80101071:	e8 b3 28 00 00       	call   80103929 <end_op>
  }
  return -1;
80101076:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010107b:	c9                   	leave  
8010107c:	c3                   	ret    
8010107d:	00 00                	add    %al,(%eax)
	...

80101080 <strcpy1>:
#include "file.h"
#include "container.h"



char* strcpy1(char *s, char *t){
80101080:	55                   	push   %ebp
80101081:	89 e5                	mov    %esp,%ebp
80101083:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80101086:	8b 45 08             	mov    0x8(%ebp),%eax
80101089:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
8010108c:	90                   	nop
8010108d:	8b 45 08             	mov    0x8(%ebp),%eax
80101090:	8d 50 01             	lea    0x1(%eax),%edx
80101093:	89 55 08             	mov    %edx,0x8(%ebp)
80101096:	8b 55 0c             	mov    0xc(%ebp),%edx
80101099:	8d 4a 01             	lea    0x1(%edx),%ecx
8010109c:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010109f:	8a 12                	mov    (%edx),%dl
801010a1:	88 10                	mov    %dl,(%eax)
801010a3:	8a 00                	mov    (%eax),%al
801010a5:	84 c0                	test   %al,%al
801010a7:	75 e4                	jne    8010108d <strcpy1+0xd>
    ;
  return os;
801010a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801010ac:	c9                   	leave  
801010ad:	c3                   	ret    

801010ae <strcmp2>:

int
strcmp2(const char *p, const char *q){
801010ae:	55                   	push   %ebp
801010af:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
801010b1:	eb 06                	jmp    801010b9 <strcmp2+0xb>
    p++, q++;
801010b3:	ff 45 08             	incl   0x8(%ebp)
801010b6:	ff 45 0c             	incl   0xc(%ebp)
  return os;
}

int
strcmp2(const char *p, const char *q){
  while(*p && *p == *q)
801010b9:	8b 45 08             	mov    0x8(%ebp),%eax
801010bc:	8a 00                	mov    (%eax),%al
801010be:	84 c0                	test   %al,%al
801010c0:	74 0e                	je     801010d0 <strcmp2+0x22>
801010c2:	8b 45 08             	mov    0x8(%ebp),%eax
801010c5:	8a 10                	mov    (%eax),%dl
801010c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801010ca:	8a 00                	mov    (%eax),%al
801010cc:	38 c2                	cmp    %al,%dl
801010ce:	74 e3                	je     801010b3 <strcmp2+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
801010d0:	8b 45 08             	mov    0x8(%ebp),%eax
801010d3:	8a 00                	mov    (%eax),%al
801010d5:	0f b6 d0             	movzbl %al,%edx
801010d8:	8b 45 0c             	mov    0xc(%ebp),%eax
801010db:	8a 00                	mov    (%eax),%al
801010dd:	0f b6 c0             	movzbl %al,%eax
801010e0:	29 c2                	sub    %eax,%edx
801010e2:	89 d0                	mov    %edx,%eax
}
801010e4:	5d                   	pop    %ebp
801010e5:	c3                   	ret    

801010e6 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
801010e6:	55                   	push   %ebp
801010e7:	89 e5                	mov    %esp,%ebp
801010e9:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
801010ec:	c7 44 24 04 9d 9d 10 	movl   $0x80109d9d,0x4(%esp)
801010f3:	80 
801010f4:	c7 04 24 80 33 11 80 	movl   $0x80113380,(%esp)
801010fb:	e8 a6 46 00 00       	call   801057a6 <initlock>
}
80101100:	c9                   	leave  
80101101:	c3                   	ret    

80101102 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101102:	55                   	push   %ebp
80101103:	89 e5                	mov    %esp,%ebp
80101105:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80101108:	c7 04 24 80 33 11 80 	movl   $0x80113380,(%esp)
8010110f:	e8 b3 46 00 00       	call   801057c7 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101114:	c7 45 f4 b4 33 11 80 	movl   $0x801133b4,-0xc(%ebp)
8010111b:	eb 29                	jmp    80101146 <filealloc+0x44>
    if(f->ref == 0){
8010111d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101120:	8b 40 04             	mov    0x4(%eax),%eax
80101123:	85 c0                	test   %eax,%eax
80101125:	75 1b                	jne    80101142 <filealloc+0x40>
      f->ref = 1;
80101127:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010112a:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101131:	c7 04 24 80 33 11 80 	movl   $0x80113380,(%esp)
80101138:	e8 f4 46 00 00       	call   80105831 <release>
      return f;
8010113d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101140:	eb 1e                	jmp    80101160 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101142:	83 45 f4 1c          	addl   $0x1c,-0xc(%ebp)
80101146:	81 7d f4 a4 3e 11 80 	cmpl   $0x80113ea4,-0xc(%ebp)
8010114d:	72 ce                	jb     8010111d <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
8010114f:	c7 04 24 80 33 11 80 	movl   $0x80113380,(%esp)
80101156:	e8 d6 46 00 00       	call   80105831 <release>
  return 0;
8010115b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101160:	c9                   	leave  
80101161:	c3                   	ret    

80101162 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101162:	55                   	push   %ebp
80101163:	89 e5                	mov    %esp,%ebp
80101165:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80101168:	c7 04 24 80 33 11 80 	movl   $0x80113380,(%esp)
8010116f:	e8 53 46 00 00       	call   801057c7 <acquire>
  if(f->ref < 1)
80101174:	8b 45 08             	mov    0x8(%ebp),%eax
80101177:	8b 40 04             	mov    0x4(%eax),%eax
8010117a:	85 c0                	test   %eax,%eax
8010117c:	7f 0c                	jg     8010118a <filedup+0x28>
    panic("filedup");
8010117e:	c7 04 24 a4 9d 10 80 	movl   $0x80109da4,(%esp)
80101185:	e8 ca f3 ff ff       	call   80100554 <panic>
  f->ref++;
8010118a:	8b 45 08             	mov    0x8(%ebp),%eax
8010118d:	8b 40 04             	mov    0x4(%eax),%eax
80101190:	8d 50 01             	lea    0x1(%eax),%edx
80101193:	8b 45 08             	mov    0x8(%ebp),%eax
80101196:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101199:	c7 04 24 80 33 11 80 	movl   $0x80113380,(%esp)
801011a0:	e8 8c 46 00 00       	call   80105831 <release>
  return f;
801011a5:	8b 45 08             	mov    0x8(%ebp),%eax
}
801011a8:	c9                   	leave  
801011a9:	c3                   	ret    

801011aa <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801011aa:	55                   	push   %ebp
801011ab:	89 e5                	mov    %esp,%ebp
801011ad:	57                   	push   %edi
801011ae:	56                   	push   %esi
801011af:	53                   	push   %ebx
801011b0:	83 ec 3c             	sub    $0x3c,%esp
  struct file ff;

  acquire(&ftable.lock);
801011b3:	c7 04 24 80 33 11 80 	movl   $0x80113380,(%esp)
801011ba:	e8 08 46 00 00       	call   801057c7 <acquire>
  if(f->ref < 1)
801011bf:	8b 45 08             	mov    0x8(%ebp),%eax
801011c2:	8b 40 04             	mov    0x4(%eax),%eax
801011c5:	85 c0                	test   %eax,%eax
801011c7:	7f 0c                	jg     801011d5 <fileclose+0x2b>
    panic("fileclose");
801011c9:	c7 04 24 ac 9d 10 80 	movl   $0x80109dac,(%esp)
801011d0:	e8 7f f3 ff ff       	call   80100554 <panic>
  if(--f->ref > 0){
801011d5:	8b 45 08             	mov    0x8(%ebp),%eax
801011d8:	8b 40 04             	mov    0x4(%eax),%eax
801011db:	8d 50 ff             	lea    -0x1(%eax),%edx
801011de:	8b 45 08             	mov    0x8(%ebp),%eax
801011e1:	89 50 04             	mov    %edx,0x4(%eax)
801011e4:	8b 45 08             	mov    0x8(%ebp),%eax
801011e7:	8b 40 04             	mov    0x4(%eax),%eax
801011ea:	85 c0                	test   %eax,%eax
801011ec:	7e 0e                	jle    801011fc <fileclose+0x52>
    release(&ftable.lock);
801011ee:	c7 04 24 80 33 11 80 	movl   $0x80113380,(%esp)
801011f5:	e8 37 46 00 00       	call   80105831 <release>
801011fa:	eb 70                	jmp    8010126c <fileclose+0xc2>
    return;
  }
  ff = *f;
801011fc:	8b 45 08             	mov    0x8(%ebp),%eax
801011ff:	8d 55 cc             	lea    -0x34(%ebp),%edx
80101202:	89 c3                	mov    %eax,%ebx
80101204:	b8 07 00 00 00       	mov    $0x7,%eax
80101209:	89 d7                	mov    %edx,%edi
8010120b:	89 de                	mov    %ebx,%esi
8010120d:	89 c1                	mov    %eax,%ecx
8010120f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  f->ref = 0;
80101211:	8b 45 08             	mov    0x8(%ebp),%eax
80101214:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010121b:	8b 45 08             	mov    0x8(%ebp),%eax
8010121e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101224:	c7 04 24 80 33 11 80 	movl   $0x80113380,(%esp)
8010122b:	e8 01 46 00 00       	call   80105831 <release>

  if(ff.type == FD_PIPE)
80101230:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101233:	83 f8 01             	cmp    $0x1,%eax
80101236:	75 17                	jne    8010124f <fileclose+0xa5>
    pipeclose(ff.pipe, ff.writable);
80101238:	8a 45 d5             	mov    -0x2b(%ebp),%al
8010123b:	0f be d0             	movsbl %al,%edx
8010123e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101241:	89 54 24 04          	mov    %edx,0x4(%esp)
80101245:	89 04 24             	mov    %eax,(%esp)
80101248:	e8 f2 2f 00 00       	call   8010423f <pipeclose>
8010124d:	eb 1d                	jmp    8010126c <fileclose+0xc2>
  else if(ff.type == FD_INODE){
8010124f:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101252:	83 f8 02             	cmp    $0x2,%eax
80101255:	75 15                	jne    8010126c <fileclose+0xc2>
    begin_op();
80101257:	e8 4b 26 00 00       	call   801038a7 <begin_op>
    iput(ff.ip);
8010125c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010125f:	89 04 24             	mov    %eax,(%esp)
80101262:	e8 0e 0a 00 00       	call   80101c75 <iput>
    end_op();
80101267:	e8 bd 26 00 00       	call   80103929 <end_op>
  }
}
8010126c:	83 c4 3c             	add    $0x3c,%esp
8010126f:	5b                   	pop    %ebx
80101270:	5e                   	pop    %esi
80101271:	5f                   	pop    %edi
80101272:	5d                   	pop    %ebp
80101273:	c3                   	ret    

80101274 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101274:	55                   	push   %ebp
80101275:	89 e5                	mov    %esp,%ebp
80101277:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
8010127a:	8b 45 08             	mov    0x8(%ebp),%eax
8010127d:	8b 00                	mov    (%eax),%eax
8010127f:	83 f8 02             	cmp    $0x2,%eax
80101282:	75 38                	jne    801012bc <filestat+0x48>
    ilock(f->ip);
80101284:	8b 45 08             	mov    0x8(%ebp),%eax
80101287:	8b 40 10             	mov    0x10(%eax),%eax
8010128a:	89 04 24             	mov    %eax,(%esp)
8010128d:	e8 95 08 00 00       	call   80101b27 <ilock>
    stati(f->ip, st);
80101292:	8b 45 08             	mov    0x8(%ebp),%eax
80101295:	8b 40 10             	mov    0x10(%eax),%eax
80101298:	8b 55 0c             	mov    0xc(%ebp),%edx
8010129b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010129f:	89 04 24             	mov    %eax,(%esp)
801012a2:	e8 d3 0c 00 00       	call   80101f7a <stati>
    iunlock(f->ip);
801012a7:	8b 45 08             	mov    0x8(%ebp),%eax
801012aa:	8b 40 10             	mov    0x10(%eax),%eax
801012ad:	89 04 24             	mov    %eax,(%esp)
801012b0:	e8 7c 09 00 00       	call   80101c31 <iunlock>
    return 0;
801012b5:	b8 00 00 00 00       	mov    $0x0,%eax
801012ba:	eb 05                	jmp    801012c1 <filestat+0x4d>
  }
  return -1;
801012bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801012c1:	c9                   	leave  
801012c2:	c3                   	ret    

801012c3 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801012c3:	55                   	push   %ebp
801012c4:	89 e5                	mov    %esp,%ebp
801012c6:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
801012c9:	8b 45 08             	mov    0x8(%ebp),%eax
801012cc:	8a 40 08             	mov    0x8(%eax),%al
801012cf:	84 c0                	test   %al,%al
801012d1:	75 0a                	jne    801012dd <fileread+0x1a>
    return -1;
801012d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012d8:	e9 9f 00 00 00       	jmp    8010137c <fileread+0xb9>
  if(f->type == FD_PIPE)
801012dd:	8b 45 08             	mov    0x8(%ebp),%eax
801012e0:	8b 00                	mov    (%eax),%eax
801012e2:	83 f8 01             	cmp    $0x1,%eax
801012e5:	75 1e                	jne    80101305 <fileread+0x42>
    return piperead(f->pipe, addr, n);
801012e7:	8b 45 08             	mov    0x8(%ebp),%eax
801012ea:	8b 40 0c             	mov    0xc(%eax),%eax
801012ed:	8b 55 10             	mov    0x10(%ebp),%edx
801012f0:	89 54 24 08          	mov    %edx,0x8(%esp)
801012f4:	8b 55 0c             	mov    0xc(%ebp),%edx
801012f7:	89 54 24 04          	mov    %edx,0x4(%esp)
801012fb:	89 04 24             	mov    %eax,(%esp)
801012fe:	e8 ba 30 00 00       	call   801043bd <piperead>
80101303:	eb 77                	jmp    8010137c <fileread+0xb9>
  if(f->type == FD_INODE){
80101305:	8b 45 08             	mov    0x8(%ebp),%eax
80101308:	8b 00                	mov    (%eax),%eax
8010130a:	83 f8 02             	cmp    $0x2,%eax
8010130d:	75 61                	jne    80101370 <fileread+0xad>
    ilock(f->ip);
8010130f:	8b 45 08             	mov    0x8(%ebp),%eax
80101312:	8b 40 10             	mov    0x10(%eax),%eax
80101315:	89 04 24             	mov    %eax,(%esp)
80101318:	e8 0a 08 00 00       	call   80101b27 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010131d:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101320:	8b 45 08             	mov    0x8(%ebp),%eax
80101323:	8b 50 14             	mov    0x14(%eax),%edx
80101326:	8b 45 08             	mov    0x8(%ebp),%eax
80101329:	8b 40 10             	mov    0x10(%eax),%eax
8010132c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101330:	89 54 24 08          	mov    %edx,0x8(%esp)
80101334:	8b 55 0c             	mov    0xc(%ebp),%edx
80101337:	89 54 24 04          	mov    %edx,0x4(%esp)
8010133b:	89 04 24             	mov    %eax,(%esp)
8010133e:	e8 7b 0c 00 00       	call   80101fbe <readi>
80101343:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101346:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010134a:	7e 11                	jle    8010135d <fileread+0x9a>
      f->off += r;
8010134c:	8b 45 08             	mov    0x8(%ebp),%eax
8010134f:	8b 50 14             	mov    0x14(%eax),%edx
80101352:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101355:	01 c2                	add    %eax,%edx
80101357:	8b 45 08             	mov    0x8(%ebp),%eax
8010135a:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010135d:	8b 45 08             	mov    0x8(%ebp),%eax
80101360:	8b 40 10             	mov    0x10(%eax),%eax
80101363:	89 04 24             	mov    %eax,(%esp)
80101366:	e8 c6 08 00 00       	call   80101c31 <iunlock>
    return r;
8010136b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010136e:	eb 0c                	jmp    8010137c <fileread+0xb9>
  }
  panic("fileread");
80101370:	c7 04 24 b6 9d 10 80 	movl   $0x80109db6,(%esp)
80101377:	e8 d8 f1 ff ff       	call   80100554 <panic>
}
8010137c:	c9                   	leave  
8010137d:	c3                   	ret    

8010137e <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010137e:	55                   	push   %ebp
8010137f:	89 e5                	mov    %esp,%ebp
80101381:	53                   	push   %ebx
80101382:	83 ec 24             	sub    $0x24,%esp
  //     x[i] = '\0';
  //     break;
  //   }
  // }

  if(f->writable == 0)
80101385:	8b 45 08             	mov    0x8(%ebp),%eax
80101388:	8a 40 09             	mov    0x9(%eax),%al
8010138b:	84 c0                	test   %al,%al
8010138d:	75 0a                	jne    80101399 <filewrite+0x1b>
    return -1;
8010138f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101394:	e9 20 01 00 00       	jmp    801014b9 <filewrite+0x13b>
  if(f->type == FD_PIPE)
80101399:	8b 45 08             	mov    0x8(%ebp),%eax
8010139c:	8b 00                	mov    (%eax),%eax
8010139e:	83 f8 01             	cmp    $0x1,%eax
801013a1:	75 21                	jne    801013c4 <filewrite+0x46>
    return pipewrite(f->pipe, addr, n);
801013a3:	8b 45 08             	mov    0x8(%ebp),%eax
801013a6:	8b 40 0c             	mov    0xc(%eax),%eax
801013a9:	8b 55 10             	mov    0x10(%ebp),%edx
801013ac:	89 54 24 08          	mov    %edx,0x8(%esp)
801013b0:	8b 55 0c             	mov    0xc(%ebp),%edx
801013b3:	89 54 24 04          	mov    %edx,0x4(%esp)
801013b7:	89 04 24             	mov    %eax,(%esp)
801013ba:	e8 12 2f 00 00       	call   801042d1 <pipewrite>
801013bf:	e9 f5 00 00 00       	jmp    801014b9 <filewrite+0x13b>
  if(f->type == FD_INODE){
801013c4:	8b 45 08             	mov    0x8(%ebp),%eax
801013c7:	8b 00                	mov    (%eax),%eax
801013c9:	83 f8 02             	cmp    $0x2,%eax
801013cc:	0f 85 db 00 00 00    	jne    801014ad <filewrite+0x12f>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
801013d2:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
801013d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801013e0:	e9 a8 00 00 00       	jmp    8010148d <filewrite+0x10f>
      int n1 = n - i;
801013e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013e8:	8b 55 10             	mov    0x10(%ebp),%edx
801013eb:	29 c2                	sub    %eax,%edx
801013ed:	89 d0                	mov    %edx,%eax
801013ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801013f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013f5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801013f8:	7e 06                	jle    80101400 <filewrite+0x82>
        n1 = max;
801013fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801013fd:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101400:	e8 a2 24 00 00       	call   801038a7 <begin_op>
      ilock(f->ip);
80101405:	8b 45 08             	mov    0x8(%ebp),%eax
80101408:	8b 40 10             	mov    0x10(%eax),%eax
8010140b:	89 04 24             	mov    %eax,(%esp)
8010140e:	e8 14 07 00 00       	call   80101b27 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0){
80101413:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101416:	8b 45 08             	mov    0x8(%ebp),%eax
80101419:	8b 50 14             	mov    0x14(%eax),%edx
8010141c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010141f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101422:	01 c3                	add    %eax,%ebx
80101424:	8b 45 08             	mov    0x8(%ebp),%eax
80101427:	8b 40 10             	mov    0x10(%eax),%eax
8010142a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010142e:	89 54 24 08          	mov    %edx,0x8(%esp)
80101432:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101436:	89 04 24             	mov    %eax,(%esp)
80101439:	e8 e4 0c 00 00       	call   80102122 <writei>
8010143e:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101441:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101445:	7e 11                	jle    80101458 <filewrite+0xda>
        f->off += r;
80101447:	8b 45 08             	mov    0x8(%ebp),%eax
8010144a:	8b 50 14             	mov    0x14(%eax),%edx
8010144d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101450:	01 c2                	add    %eax,%edx
80101452:	8b 45 08             	mov    0x8(%ebp),%eax
80101455:	89 50 14             	mov    %edx,0x14(%eax)
        // if(ticks > 0){
        //   struct superblock sb;
        //   readsb(1, &sb);
        // }
      }
      iunlock(f->ip);
80101458:	8b 45 08             	mov    0x8(%ebp),%eax
8010145b:	8b 40 10             	mov    0x10(%eax),%eax
8010145e:	89 04 24             	mov    %eax,(%esp)
80101461:	e8 cb 07 00 00       	call   80101c31 <iunlock>
      end_op();
80101466:	e8 be 24 00 00       	call   80103929 <end_op>

      if(r < 0)
8010146b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010146f:	79 02                	jns    80101473 <filewrite+0xf5>
        break;
80101471:	eb 26                	jmp    80101499 <filewrite+0x11b>
      if(r != n1)
80101473:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101476:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101479:	74 0c                	je     80101487 <filewrite+0x109>
        panic("short filewrite");
8010147b:	c7 04 24 bf 9d 10 80 	movl   $0x80109dbf,(%esp)
80101482:	e8 cd f0 ff ff       	call   80100554 <panic>
      i += r;
80101487:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010148a:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
8010148d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101490:	3b 45 10             	cmp    0x10(%ebp),%eax
80101493:	0f 8c 4c ff ff ff    	jl     801013e5 <filewrite+0x67>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80101499:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010149c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010149f:	75 05                	jne    801014a6 <filewrite+0x128>
801014a1:	8b 45 10             	mov    0x10(%ebp),%eax
801014a4:	eb 05                	jmp    801014ab <filewrite+0x12d>
801014a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801014ab:	eb 0c                	jmp    801014b9 <filewrite+0x13b>
  }
  panic("filewrite");
801014ad:	c7 04 24 cf 9d 10 80 	movl   $0x80109dcf,(%esp)
801014b4:	e8 9b f0 ff ff       	call   80100554 <panic>
}
801014b9:	83 c4 24             	add    $0x24,%esp
801014bc:	5b                   	pop    %ebx
801014bd:	5d                   	pop    %ebp
801014be:	c3                   	ret    
	...

801014c0 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801014c0:	55                   	push   %ebp
801014c1:	89 e5                	mov    %esp,%ebp
801014c3:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801014c6:	8b 45 08             	mov    0x8(%ebp),%eax
801014c9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801014d0:	00 
801014d1:	89 04 24             	mov    %eax,(%esp)
801014d4:	e8 dc ec ff ff       	call   801001b5 <bread>
801014d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801014dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014df:	83 c0 5c             	add    $0x5c,%eax
801014e2:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
801014e9:	00 
801014ea:	89 44 24 04          	mov    %eax,0x4(%esp)
801014ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801014f1:	89 04 24             	mov    %eax,(%esp)
801014f4:	e8 fa 45 00 00       	call   80105af3 <memmove>
  brelse(bp);
801014f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014fc:	89 04 24             	mov    %eax,(%esp)
801014ff:	e8 28 ed ff ff       	call   8010022c <brelse>
}
80101504:	c9                   	leave  
80101505:	c3                   	ret    

80101506 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101506:	55                   	push   %ebp
80101507:	89 e5                	mov    %esp,%ebp
80101509:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;

  bp = bread(dev, bno);
8010150c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010150f:	8b 45 08             	mov    0x8(%ebp),%eax
80101512:	89 54 24 04          	mov    %edx,0x4(%esp)
80101516:	89 04 24             	mov    %eax,(%esp)
80101519:	e8 97 ec ff ff       	call   801001b5 <bread>
8010151e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101521:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101524:	83 c0 5c             	add    $0x5c,%eax
80101527:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010152e:	00 
8010152f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101536:	00 
80101537:	89 04 24             	mov    %eax,(%esp)
8010153a:	e8 eb 44 00 00       	call   80105a2a <memset>
  log_write(bp);
8010153f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101542:	89 04 24             	mov    %eax,(%esp)
80101545:	e8 61 25 00 00       	call   80103aab <log_write>
  brelse(bp);
8010154a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010154d:	89 04 24             	mov    %eax,(%esp)
80101550:	e8 d7 ec ff ff       	call   8010022c <brelse>
}
80101555:	c9                   	leave  
80101556:	c3                   	ret    

80101557 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101557:	55                   	push   %ebp
80101558:	89 e5                	mov    %esp,%ebp
8010155a:	83 ec 28             	sub    $0x28,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
8010155d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101564:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010156b:	e9 03 01 00 00       	jmp    80101673 <balloc+0x11c>
    bp = bread(dev, BBLOCK(b, sb));
80101570:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101573:	85 c0                	test   %eax,%eax
80101575:	79 05                	jns    8010157c <balloc+0x25>
80101577:	05 ff 0f 00 00       	add    $0xfff,%eax
8010157c:	c1 f8 0c             	sar    $0xc,%eax
8010157f:	89 c2                	mov    %eax,%edx
80101581:	a1 38 3f 11 80       	mov    0x80113f38,%eax
80101586:	01 d0                	add    %edx,%eax
80101588:	89 44 24 04          	mov    %eax,0x4(%esp)
8010158c:	8b 45 08             	mov    0x8(%ebp),%eax
8010158f:	89 04 24             	mov    %eax,(%esp)
80101592:	e8 1e ec ff ff       	call   801001b5 <bread>
80101597:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010159a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801015a1:	e9 9b 00 00 00       	jmp    80101641 <balloc+0xea>
      m = 1 << (bi % 8);
801015a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015a9:	25 07 00 00 80       	and    $0x80000007,%eax
801015ae:	85 c0                	test   %eax,%eax
801015b0:	79 05                	jns    801015b7 <balloc+0x60>
801015b2:	48                   	dec    %eax
801015b3:	83 c8 f8             	or     $0xfffffff8,%eax
801015b6:	40                   	inc    %eax
801015b7:	ba 01 00 00 00       	mov    $0x1,%edx
801015bc:	88 c1                	mov    %al,%cl
801015be:	d3 e2                	shl    %cl,%edx
801015c0:	89 d0                	mov    %edx,%eax
801015c2:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801015c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015c8:	85 c0                	test   %eax,%eax
801015ca:	79 03                	jns    801015cf <balloc+0x78>
801015cc:	83 c0 07             	add    $0x7,%eax
801015cf:	c1 f8 03             	sar    $0x3,%eax
801015d2:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015d5:	8a 44 02 5c          	mov    0x5c(%edx,%eax,1),%al
801015d9:	0f b6 c0             	movzbl %al,%eax
801015dc:	23 45 e8             	and    -0x18(%ebp),%eax
801015df:	85 c0                	test   %eax,%eax
801015e1:	75 5b                	jne    8010163e <balloc+0xe7>
        bp->data[bi/8] |= m;  // Mark block in use.
801015e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015e6:	85 c0                	test   %eax,%eax
801015e8:	79 03                	jns    801015ed <balloc+0x96>
801015ea:	83 c0 07             	add    $0x7,%eax
801015ed:	c1 f8 03             	sar    $0x3,%eax
801015f0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015f3:	8a 54 02 5c          	mov    0x5c(%edx,%eax,1),%dl
801015f7:	88 d1                	mov    %dl,%cl
801015f9:	8b 55 e8             	mov    -0x18(%ebp),%edx
801015fc:	09 ca                	or     %ecx,%edx
801015fe:	88 d1                	mov    %dl,%cl
80101600:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101603:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101607:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010160a:	89 04 24             	mov    %eax,(%esp)
8010160d:	e8 99 24 00 00       	call   80103aab <log_write>
        brelse(bp);
80101612:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101615:	89 04 24             	mov    %eax,(%esp)
80101618:	e8 0f ec ff ff       	call   8010022c <brelse>
        bzero(dev, b + bi);
8010161d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101620:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101623:	01 c2                	add    %eax,%edx
80101625:	8b 45 08             	mov    0x8(%ebp),%eax
80101628:	89 54 24 04          	mov    %edx,0x4(%esp)
8010162c:	89 04 24             	mov    %eax,(%esp)
8010162f:	e8 d2 fe ff ff       	call   80101506 <bzero>
        return b + bi;
80101634:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101637:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010163a:	01 d0                	add    %edx,%eax
8010163c:	eb 51                	jmp    8010168f <balloc+0x138>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010163e:	ff 45 f0             	incl   -0x10(%ebp)
80101641:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101648:	7f 17                	jg     80101661 <balloc+0x10a>
8010164a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010164d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101650:	01 d0                	add    %edx,%eax
80101652:	89 c2                	mov    %eax,%edx
80101654:	a1 20 3f 11 80       	mov    0x80113f20,%eax
80101659:	39 c2                	cmp    %eax,%edx
8010165b:	0f 82 45 ff ff ff    	jb     801015a6 <balloc+0x4f>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101661:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101664:	89 04 24             	mov    %eax,(%esp)
80101667:	e8 c0 eb ff ff       	call   8010022c <brelse>
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
8010166c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101673:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101676:	a1 20 3f 11 80       	mov    0x80113f20,%eax
8010167b:	39 c2                	cmp    %eax,%edx
8010167d:	0f 82 ed fe ff ff    	jb     80101570 <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101683:	c7 04 24 dc 9d 10 80 	movl   $0x80109ddc,(%esp)
8010168a:	e8 c5 ee ff ff       	call   80100554 <panic>
}
8010168f:	c9                   	leave  
80101690:	c3                   	ret    

80101691 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101691:	55                   	push   %ebp
80101692:	89 e5                	mov    %esp,%ebp
80101694:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101697:	c7 44 24 04 20 3f 11 	movl   $0x80113f20,0x4(%esp)
8010169e:	80 
8010169f:	8b 45 08             	mov    0x8(%ebp),%eax
801016a2:	89 04 24             	mov    %eax,(%esp)
801016a5:	e8 16 fe ff ff       	call   801014c0 <readsb>
  bp = bread(dev, BBLOCK(b, sb));
801016aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801016ad:	c1 e8 0c             	shr    $0xc,%eax
801016b0:	89 c2                	mov    %eax,%edx
801016b2:	a1 38 3f 11 80       	mov    0x80113f38,%eax
801016b7:	01 c2                	add    %eax,%edx
801016b9:	8b 45 08             	mov    0x8(%ebp),%eax
801016bc:	89 54 24 04          	mov    %edx,0x4(%esp)
801016c0:	89 04 24             	mov    %eax,(%esp)
801016c3:	e8 ed ea ff ff       	call   801001b5 <bread>
801016c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801016cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801016ce:	25 ff 0f 00 00       	and    $0xfff,%eax
801016d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801016d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016d9:	25 07 00 00 80       	and    $0x80000007,%eax
801016de:	85 c0                	test   %eax,%eax
801016e0:	79 05                	jns    801016e7 <bfree+0x56>
801016e2:	48                   	dec    %eax
801016e3:	83 c8 f8             	or     $0xfffffff8,%eax
801016e6:	40                   	inc    %eax
801016e7:	ba 01 00 00 00       	mov    $0x1,%edx
801016ec:	88 c1                	mov    %al,%cl
801016ee:	d3 e2                	shl    %cl,%edx
801016f0:	89 d0                	mov    %edx,%eax
801016f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801016f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016f8:	85 c0                	test   %eax,%eax
801016fa:	79 03                	jns    801016ff <bfree+0x6e>
801016fc:	83 c0 07             	add    $0x7,%eax
801016ff:	c1 f8 03             	sar    $0x3,%eax
80101702:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101705:	8a 44 02 5c          	mov    0x5c(%edx,%eax,1),%al
80101709:	0f b6 c0             	movzbl %al,%eax
8010170c:	23 45 ec             	and    -0x14(%ebp),%eax
8010170f:	85 c0                	test   %eax,%eax
80101711:	75 0c                	jne    8010171f <bfree+0x8e>
    panic("freeing free block");
80101713:	c7 04 24 f2 9d 10 80 	movl   $0x80109df2,(%esp)
8010171a:	e8 35 ee ff ff       	call   80100554 <panic>
  bp->data[bi/8] &= ~m;
8010171f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101722:	85 c0                	test   %eax,%eax
80101724:	79 03                	jns    80101729 <bfree+0x98>
80101726:	83 c0 07             	add    $0x7,%eax
80101729:	c1 f8 03             	sar    $0x3,%eax
8010172c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010172f:	8a 54 02 5c          	mov    0x5c(%edx,%eax,1),%dl
80101733:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80101736:	f7 d1                	not    %ecx
80101738:	21 ca                	and    %ecx,%edx
8010173a:	88 d1                	mov    %dl,%cl
8010173c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010173f:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101743:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101746:	89 04 24             	mov    %eax,(%esp)
80101749:	e8 5d 23 00 00       	call   80103aab <log_write>
  brelse(bp);
8010174e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101751:	89 04 24             	mov    %eax,(%esp)
80101754:	e8 d3 ea ff ff       	call   8010022c <brelse>
}
80101759:	c9                   	leave  
8010175a:	c3                   	ret    

8010175b <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
8010175b:	55                   	push   %ebp
8010175c:	89 e5                	mov    %esp,%ebp
8010175e:	57                   	push   %edi
8010175f:	56                   	push   %esi
80101760:	53                   	push   %ebx
80101761:	83 ec 4c             	sub    $0x4c,%esp
  int i = 0;
80101764:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
8010176b:	c7 44 24 04 05 9e 10 	movl   $0x80109e05,0x4(%esp)
80101772:	80 
80101773:	c7 04 24 60 3f 11 80 	movl   $0x80113f60,(%esp)
8010177a:	e8 27 40 00 00       	call   801057a6 <initlock>
  for(i = 0; i < NINODE; i++) {
8010177f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101786:	eb 2b                	jmp    801017b3 <iinit+0x58>
    initsleeplock(&icache.inode[i].lock, "inode");
80101788:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010178b:	89 d0                	mov    %edx,%eax
8010178d:	c1 e0 03             	shl    $0x3,%eax
80101790:	01 d0                	add    %edx,%eax
80101792:	c1 e0 04             	shl    $0x4,%eax
80101795:	83 c0 30             	add    $0x30,%eax
80101798:	05 60 3f 11 80       	add    $0x80113f60,%eax
8010179d:	83 c0 10             	add    $0x10,%eax
801017a0:	c7 44 24 04 0c 9e 10 	movl   $0x80109e0c,0x4(%esp)
801017a7:	80 
801017a8:	89 04 24             	mov    %eax,(%esp)
801017ab:	e8 b8 3e 00 00       	call   80105668 <initsleeplock>
iinit(int dev)
{
  int i = 0;
  
  initlock(&icache.lock, "icache");
  for(i = 0; i < NINODE; i++) {
801017b0:	ff 45 e4             	incl   -0x1c(%ebp)
801017b3:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801017b7:	7e cf                	jle    80101788 <iinit+0x2d>
    initsleeplock(&icache.inode[i].lock, "inode");
  }

  readsb(dev, &sb);
801017b9:	c7 44 24 04 20 3f 11 	movl   $0x80113f20,0x4(%esp)
801017c0:	80 
801017c1:	8b 45 08             	mov    0x8(%ebp),%eax
801017c4:	89 04 24             	mov    %eax,(%esp)
801017c7:	e8 f4 fc ff ff       	call   801014c0 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801017cc:	a1 38 3f 11 80       	mov    0x80113f38,%eax
801017d1:	8b 3d 34 3f 11 80    	mov    0x80113f34,%edi
801017d7:	8b 35 30 3f 11 80    	mov    0x80113f30,%esi
801017dd:	8b 1d 2c 3f 11 80    	mov    0x80113f2c,%ebx
801017e3:	8b 0d 28 3f 11 80    	mov    0x80113f28,%ecx
801017e9:	8b 15 24 3f 11 80    	mov    0x80113f24,%edx
801017ef:	89 55 d4             	mov    %edx,-0x2c(%ebp)
801017f2:	8b 15 20 3f 11 80    	mov    0x80113f20,%edx
801017f8:	89 44 24 1c          	mov    %eax,0x1c(%esp)
801017fc:	89 7c 24 18          	mov    %edi,0x18(%esp)
80101800:	89 74 24 14          	mov    %esi,0x14(%esp)
80101804:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80101808:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010180c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010180f:	89 44 24 08          	mov    %eax,0x8(%esp)
80101813:	89 d0                	mov    %edx,%eax
80101815:	89 44 24 04          	mov    %eax,0x4(%esp)
80101819:	c7 04 24 14 9e 10 80 	movl   $0x80109e14,(%esp)
80101820:	e8 9c eb ff ff       	call   801003c1 <cprintf>
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
  sb.size_avail = (sb.nblocks/2) * 1024;
80101825:	a1 24 3f 11 80       	mov    0x80113f24,%eax
8010182a:	d1 e8                	shr    %eax
8010182c:	c1 e0 0a             	shl    $0xa,%eax
8010182f:	a3 40 3f 11 80       	mov    %eax,0x80113f40
  sb.size_used = ((sb.size - sb.nblocks)/2) * 1024;
80101834:	8b 15 20 3f 11 80    	mov    0x80113f20,%edx
8010183a:	a1 24 3f 11 80       	mov    0x80113f24,%eax
8010183f:	29 c2                	sub    %eax,%edx
80101841:	89 d0                	mov    %edx,%eax
80101843:	d1 e8                	shr    %eax
80101845:	c1 e0 0a             	shl    $0xa,%eax
80101848:	a3 44 3f 11 80       	mov    %eax,0x80113f44

  cprintf("dev %d\n", dev);
8010184d:	8b 45 08             	mov    0x8(%ebp),%eax
80101850:	89 44 24 04          	mov    %eax,0x4(%esp)
80101854:	c7 04 24 67 9e 10 80 	movl   $0x80109e67,(%esp)
8010185b:	e8 61 eb ff ff       	call   801003c1 <cprintf>
  cprintf("avail %d\n", sb.size_avail);
80101860:	a1 40 3f 11 80       	mov    0x80113f40,%eax
80101865:	89 44 24 04          	mov    %eax,0x4(%esp)
80101869:	c7 04 24 6f 9e 10 80 	movl   $0x80109e6f,(%esp)
80101870:	e8 4c eb ff ff       	call   801003c1 <cprintf>
  cprintf("used %d\n", sb.size_used);
80101875:	a1 44 3f 11 80       	mov    0x80113f44,%eax
8010187a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010187e:	c7 04 24 79 9e 10 80 	movl   $0x80109e79,(%esp)
80101885:	e8 37 eb ff ff       	call   801003c1 <cprintf>
}
8010188a:	83 c4 4c             	add    $0x4c,%esp
8010188d:	5b                   	pop    %ebx
8010188e:	5e                   	pop    %esi
8010188f:	5f                   	pop    %edi
80101890:	5d                   	pop    %ebp
80101891:	c3                   	ret    

80101892 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101892:	55                   	push   %ebp
80101893:	89 e5                	mov    %esp,%ebp
80101895:	83 ec 28             	sub    $0x28,%esp
80101898:	8b 45 0c             	mov    0xc(%ebp),%eax
8010189b:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010189f:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801018a6:	e9 9b 00 00 00       	jmp    80101946 <ialloc+0xb4>
    bp = bread(dev, IBLOCK(inum, sb));
801018ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ae:	c1 e8 03             	shr    $0x3,%eax
801018b1:	89 c2                	mov    %eax,%edx
801018b3:	a1 34 3f 11 80       	mov    0x80113f34,%eax
801018b8:	01 d0                	add    %edx,%eax
801018ba:	89 44 24 04          	mov    %eax,0x4(%esp)
801018be:	8b 45 08             	mov    0x8(%ebp),%eax
801018c1:	89 04 24             	mov    %eax,(%esp)
801018c4:	e8 ec e8 ff ff       	call   801001b5 <bread>
801018c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801018cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018cf:	8d 50 5c             	lea    0x5c(%eax),%edx
801018d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018d5:	83 e0 07             	and    $0x7,%eax
801018d8:	c1 e0 06             	shl    $0x6,%eax
801018db:	01 d0                	add    %edx,%eax
801018dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801018e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801018e3:	8b 00                	mov    (%eax),%eax
801018e5:	66 85 c0             	test   %ax,%ax
801018e8:	75 4e                	jne    80101938 <ialloc+0xa6>
      memset(dip, 0, sizeof(*dip));
801018ea:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
801018f1:	00 
801018f2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801018f9:	00 
801018fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801018fd:	89 04 24             	mov    %eax,(%esp)
80101900:	e8 25 41 00 00       	call   80105a2a <memset>
      dip->type = type;
80101905:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101908:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010190b:	66 89 02             	mov    %ax,(%edx)
      log_write(bp);   // mark it allocated on the disk
8010190e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101911:	89 04 24             	mov    %eax,(%esp)
80101914:	e8 92 21 00 00       	call   80103aab <log_write>
      brelse(bp);
80101919:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010191c:	89 04 24             	mov    %eax,(%esp)
8010191f:	e8 08 e9 ff ff       	call   8010022c <brelse>
      return iget(dev, inum);
80101924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101927:	89 44 24 04          	mov    %eax,0x4(%esp)
8010192b:	8b 45 08             	mov    0x8(%ebp),%eax
8010192e:	89 04 24             	mov    %eax,(%esp)
80101931:	e8 ea 00 00 00       	call   80101a20 <iget>
80101936:	eb 2a                	jmp    80101962 <ialloc+0xd0>
    }
    brelse(bp);
80101938:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010193b:	89 04 24             	mov    %eax,(%esp)
8010193e:	e8 e9 e8 ff ff       	call   8010022c <brelse>
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101943:	ff 45 f4             	incl   -0xc(%ebp)
80101946:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101949:	a1 28 3f 11 80       	mov    0x80113f28,%eax
8010194e:	39 c2                	cmp    %eax,%edx
80101950:	0f 82 55 ff ff ff    	jb     801018ab <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101956:	c7 04 24 82 9e 10 80 	movl   $0x80109e82,(%esp)
8010195d:	e8 f2 eb ff ff       	call   80100554 <panic>
}
80101962:	c9                   	leave  
80101963:	c3                   	ret    

80101964 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101964:	55                   	push   %ebp
80101965:	89 e5                	mov    %esp,%ebp
80101967:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010196a:	8b 45 08             	mov    0x8(%ebp),%eax
8010196d:	8b 40 04             	mov    0x4(%eax),%eax
80101970:	c1 e8 03             	shr    $0x3,%eax
80101973:	89 c2                	mov    %eax,%edx
80101975:	a1 34 3f 11 80       	mov    0x80113f34,%eax
8010197a:	01 c2                	add    %eax,%edx
8010197c:	8b 45 08             	mov    0x8(%ebp),%eax
8010197f:	8b 00                	mov    (%eax),%eax
80101981:	89 54 24 04          	mov    %edx,0x4(%esp)
80101985:	89 04 24             	mov    %eax,(%esp)
80101988:	e8 28 e8 ff ff       	call   801001b5 <bread>
8010198d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101990:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101993:	8d 50 5c             	lea    0x5c(%eax),%edx
80101996:	8b 45 08             	mov    0x8(%ebp),%eax
80101999:	8b 40 04             	mov    0x4(%eax),%eax
8010199c:	83 e0 07             	and    $0x7,%eax
8010199f:	c1 e0 06             	shl    $0x6,%eax
801019a2:	01 d0                	add    %edx,%eax
801019a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801019a7:	8b 45 08             	mov    0x8(%ebp),%eax
801019aa:	8b 40 50             	mov    0x50(%eax),%eax
801019ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
801019b0:	66 89 02             	mov    %ax,(%edx)
  dip->major = ip->major;
801019b3:	8b 45 08             	mov    0x8(%ebp),%eax
801019b6:	66 8b 40 52          	mov    0x52(%eax),%ax
801019ba:	8b 55 f0             	mov    -0x10(%ebp),%edx
801019bd:	66 89 42 02          	mov    %ax,0x2(%edx)
  dip->minor = ip->minor;
801019c1:	8b 45 08             	mov    0x8(%ebp),%eax
801019c4:	8b 40 54             	mov    0x54(%eax),%eax
801019c7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801019ca:	66 89 42 04          	mov    %ax,0x4(%edx)
  dip->nlink = ip->nlink;
801019ce:	8b 45 08             	mov    0x8(%ebp),%eax
801019d1:	66 8b 40 56          	mov    0x56(%eax),%ax
801019d5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801019d8:	66 89 42 06          	mov    %ax,0x6(%edx)
  dip->size = ip->size;
801019dc:	8b 45 08             	mov    0x8(%ebp),%eax
801019df:	8b 50 58             	mov    0x58(%eax),%edx
801019e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019e5:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801019e8:	8b 45 08             	mov    0x8(%ebp),%eax
801019eb:	8d 50 5c             	lea    0x5c(%eax),%edx
801019ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019f1:	83 c0 0c             	add    $0xc,%eax
801019f4:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
801019fb:	00 
801019fc:	89 54 24 04          	mov    %edx,0x4(%esp)
80101a00:	89 04 24             	mov    %eax,(%esp)
80101a03:	e8 eb 40 00 00       	call   80105af3 <memmove>
  log_write(bp);
80101a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a0b:	89 04 24             	mov    %eax,(%esp)
80101a0e:	e8 98 20 00 00       	call   80103aab <log_write>
  brelse(bp);
80101a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a16:	89 04 24             	mov    %eax,(%esp)
80101a19:	e8 0e e8 ff ff       	call   8010022c <brelse>
}
80101a1e:	c9                   	leave  
80101a1f:	c3                   	ret    

80101a20 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101a20:	55                   	push   %ebp
80101a21:	89 e5                	mov    %esp,%ebp
80101a23:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101a26:	c7 04 24 60 3f 11 80 	movl   $0x80113f60,(%esp)
80101a2d:	e8 95 3d 00 00       	call   801057c7 <acquire>

  // Is the inode already cached?
  empty = 0;
80101a32:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a39:	c7 45 f4 94 3f 11 80 	movl   $0x80113f94,-0xc(%ebp)
80101a40:	eb 5c                	jmp    80101a9e <iget+0x7e>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a45:	8b 40 08             	mov    0x8(%eax),%eax
80101a48:	85 c0                	test   %eax,%eax
80101a4a:	7e 35                	jle    80101a81 <iget+0x61>
80101a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a4f:	8b 00                	mov    (%eax),%eax
80101a51:	3b 45 08             	cmp    0x8(%ebp),%eax
80101a54:	75 2b                	jne    80101a81 <iget+0x61>
80101a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a59:	8b 40 04             	mov    0x4(%eax),%eax
80101a5c:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101a5f:	75 20                	jne    80101a81 <iget+0x61>
      ip->ref++;
80101a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a64:	8b 40 08             	mov    0x8(%eax),%eax
80101a67:	8d 50 01             	lea    0x1(%eax),%edx
80101a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a6d:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101a70:	c7 04 24 60 3f 11 80 	movl   $0x80113f60,(%esp)
80101a77:	e8 b5 3d 00 00       	call   80105831 <release>
      return ip;
80101a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a7f:	eb 72                	jmp    80101af3 <iget+0xd3>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101a81:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a85:	75 10                	jne    80101a97 <iget+0x77>
80101a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a8a:	8b 40 08             	mov    0x8(%eax),%eax
80101a8d:	85 c0                	test   %eax,%eax
80101a8f:	75 06                	jne    80101a97 <iget+0x77>
      empty = ip;
80101a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a94:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a97:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101a9e:	81 7d f4 b4 5b 11 80 	cmpl   $0x80115bb4,-0xc(%ebp)
80101aa5:	72 9b                	jb     80101a42 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101aa7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101aab:	75 0c                	jne    80101ab9 <iget+0x99>
    panic("iget: no inodes");
80101aad:	c7 04 24 94 9e 10 80 	movl   $0x80109e94,(%esp)
80101ab4:	e8 9b ea ff ff       	call   80100554 <panic>

  ip = empty;
80101ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101abc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ac2:	8b 55 08             	mov    0x8(%ebp),%edx
80101ac5:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aca:	8b 55 0c             	mov    0xc(%ebp),%edx
80101acd:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ad3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101add:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101ae4:	c7 04 24 60 3f 11 80 	movl   $0x80113f60,(%esp)
80101aeb:	e8 41 3d 00 00       	call   80105831 <release>

  return ip;
80101af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101af3:	c9                   	leave  
80101af4:	c3                   	ret    

80101af5 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101af5:	55                   	push   %ebp
80101af6:	89 e5                	mov    %esp,%ebp
80101af8:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101afb:	c7 04 24 60 3f 11 80 	movl   $0x80113f60,(%esp)
80101b02:	e8 c0 3c 00 00       	call   801057c7 <acquire>
  ip->ref++;
80101b07:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0a:	8b 40 08             	mov    0x8(%eax),%eax
80101b0d:	8d 50 01             	lea    0x1(%eax),%edx
80101b10:	8b 45 08             	mov    0x8(%ebp),%eax
80101b13:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b16:	c7 04 24 60 3f 11 80 	movl   $0x80113f60,(%esp)
80101b1d:	e8 0f 3d 00 00       	call   80105831 <release>
  return ip;
80101b22:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101b25:	c9                   	leave  
80101b26:	c3                   	ret    

80101b27 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101b27:	55                   	push   %ebp
80101b28:	89 e5                	mov    %esp,%ebp
80101b2a:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101b2d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b31:	74 0a                	je     80101b3d <ilock+0x16>
80101b33:	8b 45 08             	mov    0x8(%ebp),%eax
80101b36:	8b 40 08             	mov    0x8(%eax),%eax
80101b39:	85 c0                	test   %eax,%eax
80101b3b:	7f 0c                	jg     80101b49 <ilock+0x22>
    panic("ilock");
80101b3d:	c7 04 24 a4 9e 10 80 	movl   $0x80109ea4,(%esp)
80101b44:	e8 0b ea ff ff       	call   80100554 <panic>

  acquiresleep(&ip->lock);
80101b49:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4c:	83 c0 0c             	add    $0xc,%eax
80101b4f:	89 04 24             	mov    %eax,(%esp)
80101b52:	e8 4b 3b 00 00       	call   801056a2 <acquiresleep>

  if(ip->valid == 0){
80101b57:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5a:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b5d:	85 c0                	test   %eax,%eax
80101b5f:	0f 85 ca 00 00 00    	jne    80101c2f <ilock+0x108>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101b65:	8b 45 08             	mov    0x8(%ebp),%eax
80101b68:	8b 40 04             	mov    0x4(%eax),%eax
80101b6b:	c1 e8 03             	shr    $0x3,%eax
80101b6e:	89 c2                	mov    %eax,%edx
80101b70:	a1 34 3f 11 80       	mov    0x80113f34,%eax
80101b75:	01 c2                	add    %eax,%edx
80101b77:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7a:	8b 00                	mov    (%eax),%eax
80101b7c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101b80:	89 04 24             	mov    %eax,(%esp)
80101b83:	e8 2d e6 ff ff       	call   801001b5 <bread>
80101b88:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b8e:	8d 50 5c             	lea    0x5c(%eax),%edx
80101b91:	8b 45 08             	mov    0x8(%ebp),%eax
80101b94:	8b 40 04             	mov    0x4(%eax),%eax
80101b97:	83 e0 07             	and    $0x7,%eax
80101b9a:	c1 e0 06             	shl    $0x6,%eax
80101b9d:	01 d0                	add    %edx,%eax
80101b9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101ba2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ba5:	8b 00                	mov    (%eax),%eax
80101ba7:	8b 55 08             	mov    0x8(%ebp),%edx
80101baa:	66 89 42 50          	mov    %ax,0x50(%edx)
    ip->major = dip->major;
80101bae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bb1:	66 8b 40 02          	mov    0x2(%eax),%ax
80101bb5:	8b 55 08             	mov    0x8(%ebp),%edx
80101bb8:	66 89 42 52          	mov    %ax,0x52(%edx)
    ip->minor = dip->minor;
80101bbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bbf:	8b 40 04             	mov    0x4(%eax),%eax
80101bc2:	8b 55 08             	mov    0x8(%ebp),%edx
80101bc5:	66 89 42 54          	mov    %ax,0x54(%edx)
    ip->nlink = dip->nlink;
80101bc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bcc:	66 8b 40 06          	mov    0x6(%eax),%ax
80101bd0:	8b 55 08             	mov    0x8(%ebp),%edx
80101bd3:	66 89 42 56          	mov    %ax,0x56(%edx)
    ip->size = dip->size;
80101bd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bda:	8b 50 08             	mov    0x8(%eax),%edx
80101bdd:	8b 45 08             	mov    0x8(%ebp),%eax
80101be0:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101be3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101be6:	8d 50 0c             	lea    0xc(%eax),%edx
80101be9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bec:	83 c0 5c             	add    $0x5c,%eax
80101bef:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101bf6:	00 
80101bf7:	89 54 24 04          	mov    %edx,0x4(%esp)
80101bfb:	89 04 24             	mov    %eax,(%esp)
80101bfe:	e8 f0 3e 00 00       	call   80105af3 <memmove>
    brelse(bp);
80101c03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c06:	89 04 24             	mov    %eax,(%esp)
80101c09:	e8 1e e6 ff ff       	call   8010022c <brelse>
    ip->valid = 1;
80101c0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c11:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101c18:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1b:	8b 40 50             	mov    0x50(%eax),%eax
80101c1e:	66 85 c0             	test   %ax,%ax
80101c21:	75 0c                	jne    80101c2f <ilock+0x108>
      panic("ilock: no type");
80101c23:	c7 04 24 aa 9e 10 80 	movl   $0x80109eaa,(%esp)
80101c2a:	e8 25 e9 ff ff       	call   80100554 <panic>
  }
}
80101c2f:	c9                   	leave  
80101c30:	c3                   	ret    

80101c31 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101c31:	55                   	push   %ebp
80101c32:	89 e5                	mov    %esp,%ebp
80101c34:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101c37:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101c3b:	74 1c                	je     80101c59 <iunlock+0x28>
80101c3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c40:	83 c0 0c             	add    $0xc,%eax
80101c43:	89 04 24             	mov    %eax,(%esp)
80101c46:	e8 f4 3a 00 00       	call   8010573f <holdingsleep>
80101c4b:	85 c0                	test   %eax,%eax
80101c4d:	74 0a                	je     80101c59 <iunlock+0x28>
80101c4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c52:	8b 40 08             	mov    0x8(%eax),%eax
80101c55:	85 c0                	test   %eax,%eax
80101c57:	7f 0c                	jg     80101c65 <iunlock+0x34>
    panic("iunlock");
80101c59:	c7 04 24 b9 9e 10 80 	movl   $0x80109eb9,(%esp)
80101c60:	e8 ef e8 ff ff       	call   80100554 <panic>

  releasesleep(&ip->lock);
80101c65:	8b 45 08             	mov    0x8(%ebp),%eax
80101c68:	83 c0 0c             	add    $0xc,%eax
80101c6b:	89 04 24             	mov    %eax,(%esp)
80101c6e:	e8 8a 3a 00 00       	call   801056fd <releasesleep>
}
80101c73:	c9                   	leave  
80101c74:	c3                   	ret    

80101c75 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101c75:	55                   	push   %ebp
80101c76:	89 e5                	mov    %esp,%ebp
80101c78:	83 ec 28             	sub    $0x28,%esp
  acquiresleep(&ip->lock);
80101c7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7e:	83 c0 0c             	add    $0xc,%eax
80101c81:	89 04 24             	mov    %eax,(%esp)
80101c84:	e8 19 3a 00 00       	call   801056a2 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
80101c89:	8b 45 08             	mov    0x8(%ebp),%eax
80101c8c:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c8f:	85 c0                	test   %eax,%eax
80101c91:	74 5c                	je     80101cef <iput+0x7a>
80101c93:	8b 45 08             	mov    0x8(%ebp),%eax
80101c96:	66 8b 40 56          	mov    0x56(%eax),%ax
80101c9a:	66 85 c0             	test   %ax,%ax
80101c9d:	75 50                	jne    80101cef <iput+0x7a>
    acquire(&icache.lock);
80101c9f:	c7 04 24 60 3f 11 80 	movl   $0x80113f60,(%esp)
80101ca6:	e8 1c 3b 00 00       	call   801057c7 <acquire>
    int r = ip->ref;
80101cab:	8b 45 08             	mov    0x8(%ebp),%eax
80101cae:	8b 40 08             	mov    0x8(%eax),%eax
80101cb1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101cb4:	c7 04 24 60 3f 11 80 	movl   $0x80113f60,(%esp)
80101cbb:	e8 71 3b 00 00       	call   80105831 <release>
    if(r == 1){
80101cc0:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101cc4:	75 29                	jne    80101cef <iput+0x7a>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101cc6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc9:	89 04 24             	mov    %eax,(%esp)
80101ccc:	e8 86 01 00 00       	call   80101e57 <itrunc>
      ip->type = 0;
80101cd1:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd4:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101cda:	8b 45 08             	mov    0x8(%ebp),%eax
80101cdd:	89 04 24             	mov    %eax,(%esp)
80101ce0:	e8 7f fc ff ff       	call   80101964 <iupdate>
      ip->valid = 0;
80101ce5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce8:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101cef:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf2:	83 c0 0c             	add    $0xc,%eax
80101cf5:	89 04 24             	mov    %eax,(%esp)
80101cf8:	e8 00 3a 00 00       	call   801056fd <releasesleep>

  acquire(&icache.lock);
80101cfd:	c7 04 24 60 3f 11 80 	movl   $0x80113f60,(%esp)
80101d04:	e8 be 3a 00 00       	call   801057c7 <acquire>
  ip->ref--;
80101d09:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0c:	8b 40 08             	mov    0x8(%eax),%eax
80101d0f:	8d 50 ff             	lea    -0x1(%eax),%edx
80101d12:	8b 45 08             	mov    0x8(%ebp),%eax
80101d15:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101d18:	c7 04 24 60 3f 11 80 	movl   $0x80113f60,(%esp)
80101d1f:	e8 0d 3b 00 00       	call   80105831 <release>
}
80101d24:	c9                   	leave  
80101d25:	c3                   	ret    

80101d26 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101d26:	55                   	push   %ebp
80101d27:	89 e5                	mov    %esp,%ebp
80101d29:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101d2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2f:	89 04 24             	mov    %eax,(%esp)
80101d32:	e8 fa fe ff ff       	call   80101c31 <iunlock>
  iput(ip);
80101d37:	8b 45 08             	mov    0x8(%ebp),%eax
80101d3a:	89 04 24             	mov    %eax,(%esp)
80101d3d:	e8 33 ff ff ff       	call   80101c75 <iput>
}
80101d42:	c9                   	leave  
80101d43:	c3                   	ret    

80101d44 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101d44:	55                   	push   %ebp
80101d45:	89 e5                	mov    %esp,%ebp
80101d47:	53                   	push   %ebx
80101d48:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101d4b:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101d4f:	77 3e                	ja     80101d8f <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101d51:	8b 45 08             	mov    0x8(%ebp),%eax
80101d54:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d57:	83 c2 14             	add    $0x14,%edx
80101d5a:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d61:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d65:	75 20                	jne    80101d87 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101d67:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6a:	8b 00                	mov    (%eax),%eax
80101d6c:	89 04 24             	mov    %eax,(%esp)
80101d6f:	e8 e3 f7 ff ff       	call   80101557 <balloc>
80101d74:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d77:	8b 45 08             	mov    0x8(%ebp),%eax
80101d7a:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d7d:	8d 4a 14             	lea    0x14(%edx),%ecx
80101d80:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d83:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101d87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d8a:	e9 c2 00 00 00       	jmp    80101e51 <bmap+0x10d>
  }
  bn -= NDIRECT;
80101d8f:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101d93:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101d97:	0f 87 a8 00 00 00    	ja     80101e45 <bmap+0x101>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101d9d:	8b 45 08             	mov    0x8(%ebp),%eax
80101da0:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101da6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101da9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101dad:	75 1c                	jne    80101dcb <bmap+0x87>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101daf:	8b 45 08             	mov    0x8(%ebp),%eax
80101db2:	8b 00                	mov    (%eax),%eax
80101db4:	89 04 24             	mov    %eax,(%esp)
80101db7:	e8 9b f7 ff ff       	call   80101557 <balloc>
80101dbc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dbf:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dc5:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101dcb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dce:	8b 00                	mov    (%eax),%eax
80101dd0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dd3:	89 54 24 04          	mov    %edx,0x4(%esp)
80101dd7:	89 04 24             	mov    %eax,(%esp)
80101dda:	e8 d6 e3 ff ff       	call   801001b5 <bread>
80101ddf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101de2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101de5:	83 c0 5c             	add    $0x5c,%eax
80101de8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101deb:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dee:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101df5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101df8:	01 d0                	add    %edx,%eax
80101dfa:	8b 00                	mov    (%eax),%eax
80101dfc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e03:	75 30                	jne    80101e35 <bmap+0xf1>
      a[bn] = addr = balloc(ip->dev);
80101e05:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e08:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e0f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e12:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101e15:	8b 45 08             	mov    0x8(%ebp),%eax
80101e18:	8b 00                	mov    (%eax),%eax
80101e1a:	89 04 24             	mov    %eax,(%esp)
80101e1d:	e8 35 f7 ff ff       	call   80101557 <balloc>
80101e22:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e28:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101e2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e2d:	89 04 24             	mov    %eax,(%esp)
80101e30:	e8 76 1c 00 00       	call   80103aab <log_write>
    }
    brelse(bp);
80101e35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e38:	89 04 24             	mov    %eax,(%esp)
80101e3b:	e8 ec e3 ff ff       	call   8010022c <brelse>
    return addr;
80101e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e43:	eb 0c                	jmp    80101e51 <bmap+0x10d>
  }

  panic("bmap: out of range");
80101e45:	c7 04 24 c1 9e 10 80 	movl   $0x80109ec1,(%esp)
80101e4c:	e8 03 e7 ff ff       	call   80100554 <panic>
}
80101e51:	83 c4 24             	add    $0x24,%esp
80101e54:	5b                   	pop    %ebx
80101e55:	5d                   	pop    %ebp
80101e56:	c3                   	ret    

80101e57 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101e57:	55                   	push   %ebp
80101e58:	89 e5                	mov    %esp,%ebp
80101e5a:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e5d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e64:	eb 43                	jmp    80101ea9 <itrunc+0x52>
    if(ip->addrs[i]){
80101e66:	8b 45 08             	mov    0x8(%ebp),%eax
80101e69:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e6c:	83 c2 14             	add    $0x14,%edx
80101e6f:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e73:	85 c0                	test   %eax,%eax
80101e75:	74 2f                	je     80101ea6 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101e77:	8b 45 08             	mov    0x8(%ebp),%eax
80101e7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e7d:	83 c2 14             	add    $0x14,%edx
80101e80:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101e84:	8b 45 08             	mov    0x8(%ebp),%eax
80101e87:	8b 00                	mov    (%eax),%eax
80101e89:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e8d:	89 04 24             	mov    %eax,(%esp)
80101e90:	e8 fc f7 ff ff       	call   80101691 <bfree>
      ip->addrs[i] = 0;
80101e95:	8b 45 08             	mov    0x8(%ebp),%eax
80101e98:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e9b:	83 c2 14             	add    $0x14,%edx
80101e9e:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101ea5:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101ea6:	ff 45 f4             	incl   -0xc(%ebp)
80101ea9:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101ead:	7e b7                	jle    80101e66 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }

  if(ip->addrs[NDIRECT]){
80101eaf:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb2:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101eb8:	85 c0                	test   %eax,%eax
80101eba:	0f 84 a3 00 00 00    	je     80101f63 <itrunc+0x10c>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101ec0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec3:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101ec9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ecc:	8b 00                	mov    (%eax),%eax
80101ece:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ed2:	89 04 24             	mov    %eax,(%esp)
80101ed5:	e8 db e2 ff ff       	call   801001b5 <bread>
80101eda:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101edd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ee0:	83 c0 5c             	add    $0x5c,%eax
80101ee3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101ee6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101eed:	eb 3a                	jmp    80101f29 <itrunc+0xd2>
      if(a[j])
80101eef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ef2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ef9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101efc:	01 d0                	add    %edx,%eax
80101efe:	8b 00                	mov    (%eax),%eax
80101f00:	85 c0                	test   %eax,%eax
80101f02:	74 22                	je     80101f26 <itrunc+0xcf>
        bfree(ip->dev, a[j]);
80101f04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f07:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101f0e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101f11:	01 d0                	add    %edx,%eax
80101f13:	8b 10                	mov    (%eax),%edx
80101f15:	8b 45 08             	mov    0x8(%ebp),%eax
80101f18:	8b 00                	mov    (%eax),%eax
80101f1a:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f1e:	89 04 24             	mov    %eax,(%esp)
80101f21:	e8 6b f7 ff ff       	call   80101691 <bfree>
  }

  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101f26:	ff 45 f0             	incl   -0x10(%ebp)
80101f29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f2c:	83 f8 7f             	cmp    $0x7f,%eax
80101f2f:	76 be                	jbe    80101eef <itrunc+0x98>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101f31:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f34:	89 04 24             	mov    %eax,(%esp)
80101f37:	e8 f0 e2 ff ff       	call   8010022c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101f3c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f3f:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101f45:	8b 45 08             	mov    0x8(%ebp),%eax
80101f48:	8b 00                	mov    (%eax),%eax
80101f4a:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f4e:	89 04 24             	mov    %eax,(%esp)
80101f51:	e8 3b f7 ff ff       	call   80101691 <bfree>
    ip->addrs[NDIRECT] = 0;
80101f56:	8b 45 08             	mov    0x8(%ebp),%eax
80101f59:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101f60:	00 00 00 
  }

  ip->size = 0;
80101f63:	8b 45 08             	mov    0x8(%ebp),%eax
80101f66:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101f6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f70:	89 04 24             	mov    %eax,(%esp)
80101f73:	e8 ec f9 ff ff       	call   80101964 <iupdate>
}
80101f78:	c9                   	leave  
80101f79:	c3                   	ret    

80101f7a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101f7a:	55                   	push   %ebp
80101f7b:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101f7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f80:	8b 00                	mov    (%eax),%eax
80101f82:	89 c2                	mov    %eax,%edx
80101f84:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f87:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101f8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f8d:	8b 50 04             	mov    0x4(%eax),%edx
80101f90:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f93:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101f96:	8b 45 08             	mov    0x8(%ebp),%eax
80101f99:	8b 40 50             	mov    0x50(%eax),%eax
80101f9c:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f9f:	66 89 02             	mov    %ax,(%edx)
  st->nlink = ip->nlink;
80101fa2:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa5:	66 8b 40 56          	mov    0x56(%eax),%ax
80101fa9:	8b 55 0c             	mov    0xc(%ebp),%edx
80101fac:	66 89 42 0c          	mov    %ax,0xc(%edx)
  st->size = ip->size;
80101fb0:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb3:	8b 50 58             	mov    0x58(%eax),%edx
80101fb6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fb9:	89 50 10             	mov    %edx,0x10(%eax)
}
80101fbc:	5d                   	pop    %ebp
80101fbd:	c3                   	ret    

80101fbe <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101fbe:	55                   	push   %ebp
80101fbf:	89 e5                	mov    %esp,%ebp
80101fc1:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101fc4:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc7:	8b 40 50             	mov    0x50(%eax),%eax
80101fca:	66 83 f8 03          	cmp    $0x3,%ax
80101fce:	75 60                	jne    80102030 <readi+0x72>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101fd0:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd3:	66 8b 40 52          	mov    0x52(%eax),%ax
80101fd7:	66 85 c0             	test   %ax,%ax
80101fda:	78 20                	js     80101ffc <readi+0x3e>
80101fdc:	8b 45 08             	mov    0x8(%ebp),%eax
80101fdf:	66 8b 40 52          	mov    0x52(%eax),%ax
80101fe3:	66 83 f8 09          	cmp    $0x9,%ax
80101fe7:	7f 13                	jg     80101ffc <readi+0x3e>
80101fe9:	8b 45 08             	mov    0x8(%ebp),%eax
80101fec:	66 8b 40 52          	mov    0x52(%eax),%ax
80101ff0:	98                   	cwtl   
80101ff1:	8b 04 c5 c0 3e 11 80 	mov    -0x7feec140(,%eax,8),%eax
80101ff8:	85 c0                	test   %eax,%eax
80101ffa:	75 0a                	jne    80102006 <readi+0x48>
      return -1;
80101ffc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102001:	e9 1a 01 00 00       	jmp    80102120 <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80102006:	8b 45 08             	mov    0x8(%ebp),%eax
80102009:	66 8b 40 52          	mov    0x52(%eax),%ax
8010200d:	98                   	cwtl   
8010200e:	8b 04 c5 c0 3e 11 80 	mov    -0x7feec140(,%eax,8),%eax
80102015:	8b 55 14             	mov    0x14(%ebp),%edx
80102018:	89 54 24 08          	mov    %edx,0x8(%esp)
8010201c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010201f:	89 54 24 04          	mov    %edx,0x4(%esp)
80102023:	8b 55 08             	mov    0x8(%ebp),%edx
80102026:	89 14 24             	mov    %edx,(%esp)
80102029:	ff d0                	call   *%eax
8010202b:	e9 f0 00 00 00       	jmp    80102120 <readi+0x162>
  }

  if(off > ip->size || off + n < off)
80102030:	8b 45 08             	mov    0x8(%ebp),%eax
80102033:	8b 40 58             	mov    0x58(%eax),%eax
80102036:	3b 45 10             	cmp    0x10(%ebp),%eax
80102039:	72 0d                	jb     80102048 <readi+0x8a>
8010203b:	8b 45 14             	mov    0x14(%ebp),%eax
8010203e:	8b 55 10             	mov    0x10(%ebp),%edx
80102041:	01 d0                	add    %edx,%eax
80102043:	3b 45 10             	cmp    0x10(%ebp),%eax
80102046:	73 0a                	jae    80102052 <readi+0x94>
    return -1;
80102048:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010204d:	e9 ce 00 00 00       	jmp    80102120 <readi+0x162>
  if(off + n > ip->size)
80102052:	8b 45 14             	mov    0x14(%ebp),%eax
80102055:	8b 55 10             	mov    0x10(%ebp),%edx
80102058:	01 c2                	add    %eax,%edx
8010205a:	8b 45 08             	mov    0x8(%ebp),%eax
8010205d:	8b 40 58             	mov    0x58(%eax),%eax
80102060:	39 c2                	cmp    %eax,%edx
80102062:	76 0c                	jbe    80102070 <readi+0xb2>
    n = ip->size - off;
80102064:	8b 45 08             	mov    0x8(%ebp),%eax
80102067:	8b 40 58             	mov    0x58(%eax),%eax
8010206a:	2b 45 10             	sub    0x10(%ebp),%eax
8010206d:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102070:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102077:	e9 95 00 00 00       	jmp    80102111 <readi+0x153>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010207c:	8b 45 10             	mov    0x10(%ebp),%eax
8010207f:	c1 e8 09             	shr    $0x9,%eax
80102082:	89 44 24 04          	mov    %eax,0x4(%esp)
80102086:	8b 45 08             	mov    0x8(%ebp),%eax
80102089:	89 04 24             	mov    %eax,(%esp)
8010208c:	e8 b3 fc ff ff       	call   80101d44 <bmap>
80102091:	8b 55 08             	mov    0x8(%ebp),%edx
80102094:	8b 12                	mov    (%edx),%edx
80102096:	89 44 24 04          	mov    %eax,0x4(%esp)
8010209a:	89 14 24             	mov    %edx,(%esp)
8010209d:	e8 13 e1 ff ff       	call   801001b5 <bread>
801020a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801020a5:	8b 45 10             	mov    0x10(%ebp),%eax
801020a8:	25 ff 01 00 00       	and    $0x1ff,%eax
801020ad:	89 c2                	mov    %eax,%edx
801020af:	b8 00 02 00 00       	mov    $0x200,%eax
801020b4:	29 d0                	sub    %edx,%eax
801020b6:	89 c1                	mov    %eax,%ecx
801020b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020bb:	8b 55 14             	mov    0x14(%ebp),%edx
801020be:	29 c2                	sub    %eax,%edx
801020c0:	89 c8                	mov    %ecx,%eax
801020c2:	39 d0                	cmp    %edx,%eax
801020c4:	76 02                	jbe    801020c8 <readi+0x10a>
801020c6:	89 d0                	mov    %edx,%eax
801020c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
801020cb:	8b 45 10             	mov    0x10(%ebp),%eax
801020ce:	25 ff 01 00 00       	and    $0x1ff,%eax
801020d3:	8d 50 50             	lea    0x50(%eax),%edx
801020d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020d9:	01 d0                	add    %edx,%eax
801020db:	8d 50 0c             	lea    0xc(%eax),%edx
801020de:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020e1:	89 44 24 08          	mov    %eax,0x8(%esp)
801020e5:	89 54 24 04          	mov    %edx,0x4(%esp)
801020e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801020ec:	89 04 24             	mov    %eax,(%esp)
801020ef:	e8 ff 39 00 00       	call   80105af3 <memmove>
    brelse(bp);
801020f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020f7:	89 04 24             	mov    %eax,(%esp)
801020fa:	e8 2d e1 ff ff       	call   8010022c <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801020ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102102:	01 45 f4             	add    %eax,-0xc(%ebp)
80102105:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102108:	01 45 10             	add    %eax,0x10(%ebp)
8010210b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010210e:	01 45 0c             	add    %eax,0xc(%ebp)
80102111:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102114:	3b 45 14             	cmp    0x14(%ebp),%eax
80102117:	0f 82 5f ff ff ff    	jb     8010207c <readi+0xbe>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
8010211d:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102120:	c9                   	leave  
80102121:	c3                   	ret    

80102122 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102122:	55                   	push   %ebp
80102123:	89 e5                	mov    %esp,%ebp
80102125:	83 ec 38             	sub    $0x38,%esp
  uint tot, m;
  struct buf *bp;
  struct container* cont = myproc()->cont;
80102128:	e8 7a 24 00 00       	call   801045a7 <myproc>
8010212d:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102133:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int x = find(cont->name); // should be in range of 0-MAX_CONTAINERS to be utilized
80102136:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102139:	83 c0 1c             	add    $0x1c,%eax
8010213c:	89 04 24             	mov    %eax,(%esp)
8010213f:	e8 6d 74 00 00       	call   801095b1 <find>
80102144:	89 45 ec             	mov    %eax,-0x14(%ebp)

  if(ip->type == T_DEV){
80102147:	8b 45 08             	mov    0x8(%ebp),%eax
8010214a:	8b 40 50             	mov    0x50(%eax),%eax
8010214d:	66 83 f8 03          	cmp    $0x3,%ax
80102151:	75 60                	jne    801021b3 <writei+0x91>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write){
80102153:	8b 45 08             	mov    0x8(%ebp),%eax
80102156:	66 8b 40 52          	mov    0x52(%eax),%ax
8010215a:	66 85 c0             	test   %ax,%ax
8010215d:	78 20                	js     8010217f <writei+0x5d>
8010215f:	8b 45 08             	mov    0x8(%ebp),%eax
80102162:	66 8b 40 52          	mov    0x52(%eax),%ax
80102166:	66 83 f8 09          	cmp    $0x9,%ax
8010216a:	7f 13                	jg     8010217f <writei+0x5d>
8010216c:	8b 45 08             	mov    0x8(%ebp),%eax
8010216f:	66 8b 40 52          	mov    0x52(%eax),%ax
80102173:	98                   	cwtl   
80102174:	8b 04 c5 c4 3e 11 80 	mov    -0x7feec13c(,%eax,8),%eax
8010217b:	85 c0                	test   %eax,%eax
8010217d:	75 0a                	jne    80102189 <writei+0x67>
      return -1;
8010217f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102184:	e9 ac 01 00 00       	jmp    80102335 <writei+0x213>
    }
    return devsw[ip->major].write(ip, src, n);
80102189:	8b 45 08             	mov    0x8(%ebp),%eax
8010218c:	66 8b 40 52          	mov    0x52(%eax),%ax
80102190:	98                   	cwtl   
80102191:	8b 04 c5 c4 3e 11 80 	mov    -0x7feec13c(,%eax,8),%eax
80102198:	8b 55 14             	mov    0x14(%ebp),%edx
8010219b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010219f:	8b 55 0c             	mov    0xc(%ebp),%edx
801021a2:	89 54 24 04          	mov    %edx,0x4(%esp)
801021a6:	8b 55 08             	mov    0x8(%ebp),%edx
801021a9:	89 14 24             	mov    %edx,(%esp)
801021ac:	ff d0                	call   *%eax
801021ae:	e9 82 01 00 00       	jmp    80102335 <writei+0x213>
  }


  if(off > ip->size || off + n < off){
801021b3:	8b 45 08             	mov    0x8(%ebp),%eax
801021b6:	8b 40 58             	mov    0x58(%eax),%eax
801021b9:	3b 45 10             	cmp    0x10(%ebp),%eax
801021bc:	72 0d                	jb     801021cb <writei+0xa9>
801021be:	8b 45 14             	mov    0x14(%ebp),%eax
801021c1:	8b 55 10             	mov    0x10(%ebp),%edx
801021c4:	01 d0                	add    %edx,%eax
801021c6:	3b 45 10             	cmp    0x10(%ebp),%eax
801021c9:	73 0a                	jae    801021d5 <writei+0xb3>
    return -1;
801021cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021d0:	e9 60 01 00 00       	jmp    80102335 <writei+0x213>
  }
  if(off + n > MAXFILE*BSIZE){
801021d5:	8b 45 14             	mov    0x14(%ebp),%eax
801021d8:	8b 55 10             	mov    0x10(%ebp),%edx
801021db:	01 d0                	add    %edx,%eax
801021dd:	3d 00 18 01 00       	cmp    $0x11800,%eax
801021e2:	76 0a                	jbe    801021ee <writei+0xcc>
    return -1;
801021e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021e9:	e9 47 01 00 00       	jmp    80102335 <writei+0x213>
  }

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801021ee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021f5:	e9 a0 00 00 00       	jmp    8010229a <writei+0x178>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801021fa:	8b 45 10             	mov    0x10(%ebp),%eax
801021fd:	c1 e8 09             	shr    $0x9,%eax
80102200:	89 44 24 04          	mov    %eax,0x4(%esp)
80102204:	8b 45 08             	mov    0x8(%ebp),%eax
80102207:	89 04 24             	mov    %eax,(%esp)
8010220a:	e8 35 fb ff ff       	call   80101d44 <bmap>
8010220f:	8b 55 08             	mov    0x8(%ebp),%edx
80102212:	8b 12                	mov    (%edx),%edx
80102214:	89 44 24 04          	mov    %eax,0x4(%esp)
80102218:	89 14 24             	mov    %edx,(%esp)
8010221b:	e8 95 df ff ff       	call   801001b5 <bread>
80102220:	89 45 e8             	mov    %eax,-0x18(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102223:	8b 45 10             	mov    0x10(%ebp),%eax
80102226:	25 ff 01 00 00       	and    $0x1ff,%eax
8010222b:	89 c2                	mov    %eax,%edx
8010222d:	b8 00 02 00 00       	mov    $0x200,%eax
80102232:	29 d0                	sub    %edx,%eax
80102234:	89 c1                	mov    %eax,%ecx
80102236:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102239:	8b 55 14             	mov    0x14(%ebp),%edx
8010223c:	29 c2                	sub    %eax,%edx
8010223e:	89 c8                	mov    %ecx,%eax
80102240:	39 d0                	cmp    %edx,%eax
80102242:	76 02                	jbe    80102246 <writei+0x124>
80102244:	89 d0                	mov    %edx,%eax
80102246:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102249:	8b 45 10             	mov    0x10(%ebp),%eax
8010224c:	25 ff 01 00 00       	and    $0x1ff,%eax
80102251:	8d 50 50             	lea    0x50(%eax),%edx
80102254:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102257:	01 d0                	add    %edx,%eax
80102259:	8d 50 0c             	lea    0xc(%eax),%edx
8010225c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010225f:	89 44 24 08          	mov    %eax,0x8(%esp)
80102263:	8b 45 0c             	mov    0xc(%ebp),%eax
80102266:	89 44 24 04          	mov    %eax,0x4(%esp)
8010226a:	89 14 24             	mov    %edx,(%esp)
8010226d:	e8 81 38 00 00       	call   80105af3 <memmove>
    log_write(bp);
80102272:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102275:	89 04 24             	mov    %eax,(%esp)
80102278:	e8 2e 18 00 00       	call   80103aab <log_write>
    brelse(bp);
8010227d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102280:	89 04 24             	mov    %eax,(%esp)
80102283:	e8 a4 df ff ff       	call   8010022c <brelse>
  }
  if(off + n > MAXFILE*BSIZE){
    return -1;
  }

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102288:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010228b:	01 45 f4             	add    %eax,-0xc(%ebp)
8010228e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102291:	01 45 10             	add    %eax,0x10(%ebp)
80102294:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102297:	01 45 0c             	add    %eax,0xc(%ebp)
8010229a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010229d:	3b 45 14             	cmp    0x14(%ebp),%eax
801022a0:	0f 82 54 ff ff ff    	jb     801021fa <writei+0xd8>
  }


  // void set_curr_disk(int disk, int vc_num){
  //cprintf("TOTAL: %d\n", tot);
  set_os(tot);
801022a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022a9:	89 04 24             	mov    %eax,(%esp)
801022ac:	e8 2e 75 00 00       	call   801097df <set_os>
  if(x >= 0){
801022b1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801022b5:	78 56                	js     8010230d <writei+0x1eb>
    if(tot>0){
801022b7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801022bb:	74 50                	je     8010230d <writei+0x1eb>
      int before = get_curr_disk(x);
801022bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022c0:	89 04 24             	mov    %eax,(%esp)
801022c3:	e8 93 74 00 00       	call   8010975b <get_curr_disk>
801022c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
      set_curr_disk(tot, x);
801022cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022ce:	8b 55 ec             	mov    -0x14(%ebp),%edx
801022d1:	89 54 24 04          	mov    %edx,0x4(%esp)
801022d5:	89 04 24             	mov    %eax,(%esp)
801022d8:	e8 f8 75 00 00       	call   801098d5 <set_curr_disk>
      int after = get_curr_disk(x);
801022dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022e0:	89 04 24             	mov    %eax,(%esp)
801022e3:	e8 73 74 00 00       	call   8010975b <get_curr_disk>
801022e8:	89 45 dc             	mov    %eax,-0x24(%ebp)
      if(before == after){
801022eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801022ee:	3b 45 dc             	cmp    -0x24(%ebp),%eax
801022f1:	75 1a                	jne    8010230d <writei+0x1eb>
        cstop_container_helper(myproc()->cont);
801022f3:	e8 af 22 00 00       	call   801045a7 <myproc>
801022f8:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801022fe:	89 04 24             	mov    %eax,(%esp)
80102301:	e8 fa 2e 00 00       	call   80105200 <cstop_container_helper>
        return -1;
80102306:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010230b:	eb 28                	jmp    80102335 <writei+0x213>
      }
    }
  }
  if(n > 0 && off > ip->size){
8010230d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102311:	74 1f                	je     80102332 <writei+0x210>
80102313:	8b 45 08             	mov    0x8(%ebp),%eax
80102316:	8b 40 58             	mov    0x58(%eax),%eax
80102319:	3b 45 10             	cmp    0x10(%ebp),%eax
8010231c:	73 14                	jae    80102332 <writei+0x210>
    ip->size = off;
8010231e:	8b 45 08             	mov    0x8(%ebp),%eax
80102321:	8b 55 10             	mov    0x10(%ebp),%edx
80102324:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
80102327:	8b 45 08             	mov    0x8(%ebp),%eax
8010232a:	89 04 24             	mov    %eax,(%esp)
8010232d:	e8 32 f6 ff ff       	call   80101964 <iupdate>
  }
  return n;
80102332:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102335:	c9                   	leave  
80102336:	c3                   	ret    

80102337 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102337:	55                   	push   %ebp
80102338:	89 e5                	mov    %esp,%ebp
8010233a:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
8010233d:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102344:	00 
80102345:	8b 45 0c             	mov    0xc(%ebp),%eax
80102348:	89 44 24 04          	mov    %eax,0x4(%esp)
8010234c:	8b 45 08             	mov    0x8(%ebp),%eax
8010234f:	89 04 24             	mov    %eax,(%esp)
80102352:	e8 3b 38 00 00       	call   80105b92 <strncmp>
}
80102357:	c9                   	leave  
80102358:	c3                   	ret    

80102359 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102359:	55                   	push   %ebp
8010235a:	89 e5                	mov    %esp,%ebp
8010235c:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
8010235f:	8b 45 08             	mov    0x8(%ebp),%eax
80102362:	8b 40 50             	mov    0x50(%eax),%eax
80102365:	66 83 f8 01          	cmp    $0x1,%ax
80102369:	74 0c                	je     80102377 <dirlookup+0x1e>
    panic("dirlookup not DIR");
8010236b:	c7 04 24 d4 9e 10 80 	movl   $0x80109ed4,(%esp)
80102372:	e8 dd e1 ff ff       	call   80100554 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102377:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010237e:	e9 86 00 00 00       	jmp    80102409 <dirlookup+0xb0>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102383:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010238a:	00 
8010238b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010238e:	89 44 24 08          	mov    %eax,0x8(%esp)
80102392:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102395:	89 44 24 04          	mov    %eax,0x4(%esp)
80102399:	8b 45 08             	mov    0x8(%ebp),%eax
8010239c:	89 04 24             	mov    %eax,(%esp)
8010239f:	e8 1a fc ff ff       	call   80101fbe <readi>
801023a4:	83 f8 10             	cmp    $0x10,%eax
801023a7:	74 0c                	je     801023b5 <dirlookup+0x5c>
      panic("dirlookup read");
801023a9:	c7 04 24 e6 9e 10 80 	movl   $0x80109ee6,(%esp)
801023b0:	e8 9f e1 ff ff       	call   80100554 <panic>
    if(de.inum == 0)
801023b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801023b8:	66 85 c0             	test   %ax,%ax
801023bb:	75 02                	jne    801023bf <dirlookup+0x66>
      continue;
801023bd:	eb 46                	jmp    80102405 <dirlookup+0xac>
    if(namecmp(name, de.name) == 0){
801023bf:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023c2:	83 c0 02             	add    $0x2,%eax
801023c5:	89 44 24 04          	mov    %eax,0x4(%esp)
801023c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801023cc:	89 04 24             	mov    %eax,(%esp)
801023cf:	e8 63 ff ff ff       	call   80102337 <namecmp>
801023d4:	85 c0                	test   %eax,%eax
801023d6:	75 2d                	jne    80102405 <dirlookup+0xac>
      // entry matches path element
      if(poff)
801023d8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801023dc:	74 08                	je     801023e6 <dirlookup+0x8d>
        *poff = off;
801023de:	8b 45 10             	mov    0x10(%ebp),%eax
801023e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801023e4:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801023e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801023e9:	0f b7 c0             	movzwl %ax,%eax
801023ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
801023ef:	8b 45 08             	mov    0x8(%ebp),%eax
801023f2:	8b 00                	mov    (%eax),%eax
801023f4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023f7:	89 54 24 04          	mov    %edx,0x4(%esp)
801023fb:	89 04 24             	mov    %eax,(%esp)
801023fe:	e8 1d f6 ff ff       	call   80101a20 <iget>
80102403:	eb 18                	jmp    8010241d <dirlookup+0xc4>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102405:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102409:	8b 45 08             	mov    0x8(%ebp),%eax
8010240c:	8b 40 58             	mov    0x58(%eax),%eax
8010240f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102412:	0f 87 6b ff ff ff    	ja     80102383 <dirlookup+0x2a>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102418:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010241d:	c9                   	leave  
8010241e:	c3                   	ret    

8010241f <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010241f:	55                   	push   %ebp
80102420:	89 e5                	mov    %esp,%ebp
80102422:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102425:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010242c:	00 
8010242d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102430:	89 44 24 04          	mov    %eax,0x4(%esp)
80102434:	8b 45 08             	mov    0x8(%ebp),%eax
80102437:	89 04 24             	mov    %eax,(%esp)
8010243a:	e8 1a ff ff ff       	call   80102359 <dirlookup>
8010243f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102442:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102446:	74 15                	je     8010245d <dirlink+0x3e>
    iput(ip);
80102448:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010244b:	89 04 24             	mov    %eax,(%esp)
8010244e:	e8 22 f8 ff ff       	call   80101c75 <iput>
    return -1;
80102453:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102458:	e9 b6 00 00 00       	jmp    80102513 <dirlink+0xf4>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010245d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102464:	eb 45                	jmp    801024ab <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102466:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102469:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102470:	00 
80102471:	89 44 24 08          	mov    %eax,0x8(%esp)
80102475:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102478:	89 44 24 04          	mov    %eax,0x4(%esp)
8010247c:	8b 45 08             	mov    0x8(%ebp),%eax
8010247f:	89 04 24             	mov    %eax,(%esp)
80102482:	e8 37 fb ff ff       	call   80101fbe <readi>
80102487:	83 f8 10             	cmp    $0x10,%eax
8010248a:	74 0c                	je     80102498 <dirlink+0x79>
      panic("dirlink read");
8010248c:	c7 04 24 f5 9e 10 80 	movl   $0x80109ef5,(%esp)
80102493:	e8 bc e0 ff ff       	call   80100554 <panic>
    if(de.inum == 0)
80102498:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010249b:	66 85 c0             	test   %ax,%ax
8010249e:	75 02                	jne    801024a2 <dirlink+0x83>
      break;
801024a0:	eb 16                	jmp    801024b8 <dirlink+0x99>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801024a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024a5:	83 c0 10             	add    $0x10,%eax
801024a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
801024ae:	8b 45 08             	mov    0x8(%ebp),%eax
801024b1:	8b 40 58             	mov    0x58(%eax),%eax
801024b4:	39 c2                	cmp    %eax,%edx
801024b6:	72 ae                	jb     80102466 <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
801024b8:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801024bf:	00 
801024c0:	8b 45 0c             	mov    0xc(%ebp),%eax
801024c3:	89 44 24 04          	mov    %eax,0x4(%esp)
801024c7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024ca:	83 c0 02             	add    $0x2,%eax
801024cd:	89 04 24             	mov    %eax,(%esp)
801024d0:	e8 0b 37 00 00       	call   80105be0 <strncpy>
  de.inum = inum;
801024d5:	8b 45 10             	mov    0x10(%ebp),%eax
801024d8:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801024dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024df:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801024e6:	00 
801024e7:	89 44 24 08          	mov    %eax,0x8(%esp)
801024eb:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024ee:	89 44 24 04          	mov    %eax,0x4(%esp)
801024f2:	8b 45 08             	mov    0x8(%ebp),%eax
801024f5:	89 04 24             	mov    %eax,(%esp)
801024f8:	e8 25 fc ff ff       	call   80102122 <writei>
801024fd:	83 f8 10             	cmp    $0x10,%eax
80102500:	74 0c                	je     8010250e <dirlink+0xef>
    panic("dirlink");
80102502:	c7 04 24 02 9f 10 80 	movl   $0x80109f02,(%esp)
80102509:	e8 46 e0 ff ff       	call   80100554 <panic>

  return 0;
8010250e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102513:	c9                   	leave  
80102514:	c3                   	ret    

80102515 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102515:	55                   	push   %ebp
80102516:	89 e5                	mov    %esp,%ebp
80102518:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
8010251b:	eb 03                	jmp    80102520 <skipelem+0xb>
    path++;
8010251d:	ff 45 08             	incl   0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102520:	8b 45 08             	mov    0x8(%ebp),%eax
80102523:	8a 00                	mov    (%eax),%al
80102525:	3c 2f                	cmp    $0x2f,%al
80102527:	74 f4                	je     8010251d <skipelem+0x8>
    path++;
  if(*path == 0)
80102529:	8b 45 08             	mov    0x8(%ebp),%eax
8010252c:	8a 00                	mov    (%eax),%al
8010252e:	84 c0                	test   %al,%al
80102530:	75 0a                	jne    8010253c <skipelem+0x27>
    return 0;
80102532:	b8 00 00 00 00       	mov    $0x0,%eax
80102537:	e9 81 00 00 00       	jmp    801025bd <skipelem+0xa8>
  s = path;
8010253c:	8b 45 08             	mov    0x8(%ebp),%eax
8010253f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102542:	eb 03                	jmp    80102547 <skipelem+0x32>
    path++;
80102544:	ff 45 08             	incl   0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102547:	8b 45 08             	mov    0x8(%ebp),%eax
8010254a:	8a 00                	mov    (%eax),%al
8010254c:	3c 2f                	cmp    $0x2f,%al
8010254e:	74 09                	je     80102559 <skipelem+0x44>
80102550:	8b 45 08             	mov    0x8(%ebp),%eax
80102553:	8a 00                	mov    (%eax),%al
80102555:	84 c0                	test   %al,%al
80102557:	75 eb                	jne    80102544 <skipelem+0x2f>
    path++;
  len = path - s;
80102559:	8b 55 08             	mov    0x8(%ebp),%edx
8010255c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010255f:	29 c2                	sub    %eax,%edx
80102561:	89 d0                	mov    %edx,%eax
80102563:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102566:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
8010256a:	7e 1c                	jle    80102588 <skipelem+0x73>
    memmove(name, s, DIRSIZ);
8010256c:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102573:	00 
80102574:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102577:	89 44 24 04          	mov    %eax,0x4(%esp)
8010257b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010257e:	89 04 24             	mov    %eax,(%esp)
80102581:	e8 6d 35 00 00       	call   80105af3 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102586:	eb 29                	jmp    801025b1 <skipelem+0x9c>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
80102588:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010258b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010258f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102592:	89 44 24 04          	mov    %eax,0x4(%esp)
80102596:	8b 45 0c             	mov    0xc(%ebp),%eax
80102599:	89 04 24             	mov    %eax,(%esp)
8010259c:	e8 52 35 00 00       	call   80105af3 <memmove>
    name[len] = 0;
801025a1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801025a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801025a7:	01 d0                	add    %edx,%eax
801025a9:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801025ac:	eb 03                	jmp    801025b1 <skipelem+0x9c>
    path++;
801025ae:	ff 45 08             	incl   0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801025b1:	8b 45 08             	mov    0x8(%ebp),%eax
801025b4:	8a 00                	mov    (%eax),%al
801025b6:	3c 2f                	cmp    $0x2f,%al
801025b8:	74 f4                	je     801025ae <skipelem+0x99>
    path++;
  return path;
801025ba:	8b 45 08             	mov    0x8(%ebp),%eax
}
801025bd:	c9                   	leave  
801025be:	c3                   	ret    

801025bf <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801025bf:	55                   	push   %ebp
801025c0:	89 e5                	mov    %esp,%ebp
801025c2:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
801025c5:	8b 45 08             	mov    0x8(%ebp),%eax
801025c8:	8a 00                	mov    (%eax),%al
801025ca:	3c 2f                	cmp    $0x2f,%al
801025cc:	75 19                	jne    801025e7 <namex+0x28>
    ip = iget(ROOTDEV, ROOTINO);
801025ce:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801025d5:	00 
801025d6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801025dd:	e8 3e f4 ff ff       	call   80101a20 <iget>
801025e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801025e5:	eb 13                	jmp    801025fa <namex+0x3b>
  else
    ip = idup(myproc()->cwd);
801025e7:	e8 bb 1f 00 00       	call   801045a7 <myproc>
801025ec:	8b 40 68             	mov    0x68(%eax),%eax
801025ef:	89 04 24             	mov    %eax,(%esp)
801025f2:	e8 fe f4 ff ff       	call   80101af5 <idup>
801025f7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  struct proc* p = myproc();
801025fa:	e8 a8 1f 00 00       	call   801045a7 <myproc>
801025ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct container* cont = NULL;
80102602:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(p != NULL){
80102609:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010260d:	74 0c                	je     8010261b <namex+0x5c>
    cont = p->cont;
8010260f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102612:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102618:	89 45 f0             	mov    %eax,-0x10(%ebp)
  }

  if(strncmp(path, "..",2) == 0 && cont != NULL && cont->root->inum == ip->inum){
8010261b:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
80102622:	00 
80102623:	c7 44 24 04 0a 9f 10 	movl   $0x80109f0a,0x4(%esp)
8010262a:	80 
8010262b:	8b 45 08             	mov    0x8(%ebp),%eax
8010262e:	89 04 24             	mov    %eax,(%esp)
80102631:	e8 5c 35 00 00       	call   80105b92 <strncmp>
80102636:	85 c0                	test   %eax,%eax
80102638:	75 21                	jne    8010265b <namex+0x9c>
8010263a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010263e:	74 1b                	je     8010265b <namex+0x9c>
80102640:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102643:	8b 40 3c             	mov    0x3c(%eax),%eax
80102646:	8b 50 04             	mov    0x4(%eax),%edx
80102649:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010264c:	8b 40 04             	mov    0x4(%eax),%eax
8010264f:	39 c2                	cmp    %eax,%edx
80102651:	75 08                	jne    8010265b <namex+0x9c>
    return ip;
80102653:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102656:	e9 45 01 00 00       	jmp    801027a0 <namex+0x1e1>
  }
  
  while((path = skipelem(path, name)) != 0){
8010265b:	e9 06 01 00 00       	jmp    80102766 <namex+0x1a7>
    ilock(ip);
80102660:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102663:	89 04 24             	mov    %eax,(%esp)
80102666:	e8 bc f4 ff ff       	call   80101b27 <ilock>

    if(ip->type != T_DIR){
8010266b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010266e:	8b 40 50             	mov    0x50(%eax),%eax
80102671:	66 83 f8 01          	cmp    $0x1,%ax
80102675:	74 15                	je     8010268c <namex+0xcd>
      iunlockput(ip);
80102677:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010267a:	89 04 24             	mov    %eax,(%esp)
8010267d:	e8 a4 f6 ff ff       	call   80101d26 <iunlockput>
      return 0;
80102682:	b8 00 00 00 00       	mov    $0x0,%eax
80102687:	e9 14 01 00 00       	jmp    801027a0 <namex+0x1e1>
    }

    if(strncmp(path, "..",2) == 0 && cont != NULL && cont->root->inum == ip->inum){
8010268c:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
80102693:	00 
80102694:	c7 44 24 04 0a 9f 10 	movl   $0x80109f0a,0x4(%esp)
8010269b:	80 
8010269c:	8b 45 08             	mov    0x8(%ebp),%eax
8010269f:	89 04 24             	mov    %eax,(%esp)
801026a2:	e8 eb 34 00 00       	call   80105b92 <strncmp>
801026a7:	85 c0                	test   %eax,%eax
801026a9:	75 2c                	jne    801026d7 <namex+0x118>
801026ab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801026af:	74 26                	je     801026d7 <namex+0x118>
801026b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026b4:	8b 40 3c             	mov    0x3c(%eax),%eax
801026b7:	8b 50 04             	mov    0x4(%eax),%edx
801026ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026bd:	8b 40 04             	mov    0x4(%eax),%eax
801026c0:	39 c2                	cmp    %eax,%edx
801026c2:	75 13                	jne    801026d7 <namex+0x118>
      iunlock(ip);
801026c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026c7:	89 04 24             	mov    %eax,(%esp)
801026ca:	e8 62 f5 ff ff       	call   80101c31 <iunlock>
      return ip;
801026cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026d2:	e9 c9 00 00 00       	jmp    801027a0 <namex+0x1e1>
    }

    if(cont != NULL && ip->inum == ROOTINO){
801026d7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801026db:	74 21                	je     801026fe <namex+0x13f>
801026dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026e0:	8b 40 04             	mov    0x4(%eax),%eax
801026e3:	83 f8 01             	cmp    $0x1,%eax
801026e6:	75 16                	jne    801026fe <namex+0x13f>
      iunlock(ip);
801026e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026eb:	89 04 24             	mov    %eax,(%esp)
801026ee:	e8 3e f5 ff ff       	call   80101c31 <iunlock>
      return cont->root;
801026f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026f6:	8b 40 3c             	mov    0x3c(%eax),%eax
801026f9:	e9 a2 00 00 00       	jmp    801027a0 <namex+0x1e1>
    }

    if(nameiparent && *path == '\0'){
801026fe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102702:	74 1c                	je     80102720 <namex+0x161>
80102704:	8b 45 08             	mov    0x8(%ebp),%eax
80102707:	8a 00                	mov    (%eax),%al
80102709:	84 c0                	test   %al,%al
8010270b:	75 13                	jne    80102720 <namex+0x161>
      // Stop one level early.
      iunlock(ip);
8010270d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102710:	89 04 24             	mov    %eax,(%esp)
80102713:	e8 19 f5 ff ff       	call   80101c31 <iunlock>
      return ip;
80102718:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010271b:	e9 80 00 00 00       	jmp    801027a0 <namex+0x1e1>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102720:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102727:	00 
80102728:	8b 45 10             	mov    0x10(%ebp),%eax
8010272b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010272f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102732:	89 04 24             	mov    %eax,(%esp)
80102735:	e8 1f fc ff ff       	call   80102359 <dirlookup>
8010273a:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010273d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80102741:	75 12                	jne    80102755 <namex+0x196>
      iunlockput(ip);
80102743:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102746:	89 04 24             	mov    %eax,(%esp)
80102749:	e8 d8 f5 ff ff       	call   80101d26 <iunlockput>
      return 0;
8010274e:	b8 00 00 00 00       	mov    $0x0,%eax
80102753:	eb 4b                	jmp    801027a0 <namex+0x1e1>
    }
    iunlockput(ip);
80102755:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102758:	89 04 24             	mov    %eax,(%esp)
8010275b:	e8 c6 f5 ff ff       	call   80101d26 <iunlockput>

    ip = next;
80102760:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102763:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(strncmp(path, "..",2) == 0 && cont != NULL && cont->root->inum == ip->inum){
    return ip;
  }
  
  while((path = skipelem(path, name)) != 0){
80102766:	8b 45 10             	mov    0x10(%ebp),%eax
80102769:	89 44 24 04          	mov    %eax,0x4(%esp)
8010276d:	8b 45 08             	mov    0x8(%ebp),%eax
80102770:	89 04 24             	mov    %eax,(%esp)
80102773:	e8 9d fd ff ff       	call   80102515 <skipelem>
80102778:	89 45 08             	mov    %eax,0x8(%ebp)
8010277b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010277f:	0f 85 db fe ff ff    	jne    80102660 <namex+0xa1>
    }
    iunlockput(ip);

    ip = next;
  }
  if(nameiparent){
80102785:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102789:	74 12                	je     8010279d <namex+0x1de>
    iput(ip);
8010278b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010278e:	89 04 24             	mov    %eax,(%esp)
80102791:	e8 df f4 ff ff       	call   80101c75 <iput>
    return 0;
80102796:	b8 00 00 00 00       	mov    $0x0,%eax
8010279b:	eb 03                	jmp    801027a0 <namex+0x1e1>
  }

  
  return ip;
8010279d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801027a0:	c9                   	leave  
801027a1:	c3                   	ret    

801027a2 <namei>:

struct inode*
namei(char *path)
{
801027a2:	55                   	push   %ebp
801027a3:	89 e5                	mov    %esp,%ebp
801027a5:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801027a8:	8d 45 ea             	lea    -0x16(%ebp),%eax
801027ab:	89 44 24 08          	mov    %eax,0x8(%esp)
801027af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801027b6:	00 
801027b7:	8b 45 08             	mov    0x8(%ebp),%eax
801027ba:	89 04 24             	mov    %eax,(%esp)
801027bd:	e8 fd fd ff ff       	call   801025bf <namex>
}
801027c2:	c9                   	leave  
801027c3:	c3                   	ret    

801027c4 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801027c4:	55                   	push   %ebp
801027c5:	89 e5                	mov    %esp,%ebp
801027c7:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
801027ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801027cd:	89 44 24 08          	mov    %eax,0x8(%esp)
801027d1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801027d8:	00 
801027d9:	8b 45 08             	mov    0x8(%ebp),%eax
801027dc:	89 04 24             	mov    %eax,(%esp)
801027df:	e8 db fd ff ff       	call   801025bf <namex>
}
801027e4:	c9                   	leave  
801027e5:	c3                   	ret    
	...

801027e8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801027e8:	55                   	push   %ebp
801027e9:	89 e5                	mov    %esp,%ebp
801027eb:	83 ec 14             	sub    $0x14,%esp
801027ee:	8b 45 08             	mov    0x8(%ebp),%eax
801027f1:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801027f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801027f8:	89 c2                	mov    %eax,%edx
801027fa:	ec                   	in     (%dx),%al
801027fb:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801027fe:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102801:	c9                   	leave  
80102802:	c3                   	ret    

80102803 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102803:	55                   	push   %ebp
80102804:	89 e5                	mov    %esp,%ebp
80102806:	57                   	push   %edi
80102807:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102808:	8b 55 08             	mov    0x8(%ebp),%edx
8010280b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010280e:	8b 45 10             	mov    0x10(%ebp),%eax
80102811:	89 cb                	mov    %ecx,%ebx
80102813:	89 df                	mov    %ebx,%edi
80102815:	89 c1                	mov    %eax,%ecx
80102817:	fc                   	cld    
80102818:	f3 6d                	rep insl (%dx),%es:(%edi)
8010281a:	89 c8                	mov    %ecx,%eax
8010281c:	89 fb                	mov    %edi,%ebx
8010281e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102821:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102824:	5b                   	pop    %ebx
80102825:	5f                   	pop    %edi
80102826:	5d                   	pop    %ebp
80102827:	c3                   	ret    

80102828 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102828:	55                   	push   %ebp
80102829:	89 e5                	mov    %esp,%ebp
8010282b:	83 ec 08             	sub    $0x8,%esp
8010282e:	8b 45 08             	mov    0x8(%ebp),%eax
80102831:	8b 55 0c             	mov    0xc(%ebp),%edx
80102834:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102838:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010283b:	8a 45 f8             	mov    -0x8(%ebp),%al
8010283e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80102841:	ee                   	out    %al,(%dx)
}
80102842:	c9                   	leave  
80102843:	c3                   	ret    

80102844 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102844:	55                   	push   %ebp
80102845:	89 e5                	mov    %esp,%ebp
80102847:	56                   	push   %esi
80102848:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102849:	8b 55 08             	mov    0x8(%ebp),%edx
8010284c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010284f:	8b 45 10             	mov    0x10(%ebp),%eax
80102852:	89 cb                	mov    %ecx,%ebx
80102854:	89 de                	mov    %ebx,%esi
80102856:	89 c1                	mov    %eax,%ecx
80102858:	fc                   	cld    
80102859:	f3 6f                	rep outsl %ds:(%esi),(%dx)
8010285b:	89 c8                	mov    %ecx,%eax
8010285d:	89 f3                	mov    %esi,%ebx
8010285f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102862:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102865:	5b                   	pop    %ebx
80102866:	5e                   	pop    %esi
80102867:	5d                   	pop    %ebp
80102868:	c3                   	ret    

80102869 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102869:	55                   	push   %ebp
8010286a:	89 e5                	mov    %esp,%ebp
8010286c:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
8010286f:	90                   	nop
80102870:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102877:	e8 6c ff ff ff       	call   801027e8 <inb>
8010287c:	0f b6 c0             	movzbl %al,%eax
8010287f:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102882:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102885:	25 c0 00 00 00       	and    $0xc0,%eax
8010288a:	83 f8 40             	cmp    $0x40,%eax
8010288d:	75 e1                	jne    80102870 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
8010288f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102893:	74 11                	je     801028a6 <idewait+0x3d>
80102895:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102898:	83 e0 21             	and    $0x21,%eax
8010289b:	85 c0                	test   %eax,%eax
8010289d:	74 07                	je     801028a6 <idewait+0x3d>
    return -1;
8010289f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801028a4:	eb 05                	jmp    801028ab <idewait+0x42>
  return 0;
801028a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801028ab:	c9                   	leave  
801028ac:	c3                   	ret    

801028ad <ideinit>:

void
ideinit(void)
{
801028ad:	55                   	push   %ebp
801028ae:	89 e5                	mov    %esp,%ebp
801028b0:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
801028b3:	c7 44 24 04 0d 9f 10 	movl   $0x80109f0d,0x4(%esp)
801028ba:	80 
801028bb:	c7 04 24 20 d9 10 80 	movl   $0x8010d920,(%esp)
801028c2:	e8 df 2e 00 00       	call   801057a6 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
801028c7:	a1 a0 62 11 80       	mov    0x801162a0,%eax
801028cc:	48                   	dec    %eax
801028cd:	89 44 24 04          	mov    %eax,0x4(%esp)
801028d1:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
801028d8:	e8 66 04 00 00       	call   80102d43 <ioapicenable>
  idewait(0);
801028dd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801028e4:	e8 80 ff ff ff       	call   80102869 <idewait>

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801028e9:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
801028f0:	00 
801028f1:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801028f8:	e8 2b ff ff ff       	call   80102828 <outb>
  for(i=0; i<1000; i++){
801028fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102904:	eb 1f                	jmp    80102925 <ideinit+0x78>
    if(inb(0x1f7) != 0){
80102906:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010290d:	e8 d6 fe ff ff       	call   801027e8 <inb>
80102912:	84 c0                	test   %al,%al
80102914:	74 0c                	je     80102922 <ideinit+0x75>
      havedisk1 = 1;
80102916:	c7 05 58 d9 10 80 01 	movl   $0x1,0x8010d958
8010291d:	00 00 00 
      break;
80102920:	eb 0c                	jmp    8010292e <ideinit+0x81>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102922:	ff 45 f4             	incl   -0xc(%ebp)
80102925:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
8010292c:	7e d8                	jle    80102906 <ideinit+0x59>
      break;
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
8010292e:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
80102935:	00 
80102936:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010293d:	e8 e6 fe ff ff       	call   80102828 <outb>
}
80102942:	c9                   	leave  
80102943:	c3                   	ret    

80102944 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102944:	55                   	push   %ebp
80102945:	89 e5                	mov    %esp,%ebp
80102947:	83 ec 28             	sub    $0x28,%esp
  if(b == 0)
8010294a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010294e:	75 0c                	jne    8010295c <idestart+0x18>
    panic("idestart");
80102950:	c7 04 24 11 9f 10 80 	movl   $0x80109f11,(%esp)
80102957:	e8 f8 db ff ff       	call   80100554 <panic>
  if(b->blockno >= FSSIZE)
8010295c:	8b 45 08             	mov    0x8(%ebp),%eax
8010295f:	8b 40 08             	mov    0x8(%eax),%eax
80102962:	3d 1f 4e 00 00       	cmp    $0x4e1f,%eax
80102967:	76 0c                	jbe    80102975 <idestart+0x31>
    panic("incorrect blockno");
80102969:	c7 04 24 1a 9f 10 80 	movl   $0x80109f1a,(%esp)
80102970:	e8 df db ff ff       	call   80100554 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102975:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
8010297c:	8b 45 08             	mov    0x8(%ebp),%eax
8010297f:	8b 50 08             	mov    0x8(%eax),%edx
80102982:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102985:	0f af c2             	imul   %edx,%eax
80102988:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
8010298b:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010298f:	75 07                	jne    80102998 <idestart+0x54>
80102991:	b8 20 00 00 00       	mov    $0x20,%eax
80102996:	eb 05                	jmp    8010299d <idestart+0x59>
80102998:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010299d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
801029a0:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801029a4:	75 07                	jne    801029ad <idestart+0x69>
801029a6:	b8 30 00 00 00       	mov    $0x30,%eax
801029ab:	eb 05                	jmp    801029b2 <idestart+0x6e>
801029ad:	b8 c5 00 00 00       	mov    $0xc5,%eax
801029b2:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
801029b5:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
801029b9:	7e 0c                	jle    801029c7 <idestart+0x83>
801029bb:	c7 04 24 11 9f 10 80 	movl   $0x80109f11,(%esp)
801029c2:	e8 8d db ff ff       	call   80100554 <panic>

  idewait(0);
801029c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801029ce:	e8 96 fe ff ff       	call   80102869 <idewait>
  outb(0x3f6, 0);  // generate interrupt
801029d3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801029da:	00 
801029db:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
801029e2:	e8 41 fe ff ff       	call   80102828 <outb>
  outb(0x1f2, sector_per_block);  // number of sectors
801029e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029ea:	0f b6 c0             	movzbl %al,%eax
801029ed:	89 44 24 04          	mov    %eax,0x4(%esp)
801029f1:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
801029f8:	e8 2b fe ff ff       	call   80102828 <outb>
  outb(0x1f3, sector & 0xff);
801029fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102a00:	0f b6 c0             	movzbl %al,%eax
80102a03:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a07:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102a0e:	e8 15 fe ff ff       	call   80102828 <outb>
  outb(0x1f4, (sector >> 8) & 0xff);
80102a13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102a16:	c1 f8 08             	sar    $0x8,%eax
80102a19:	0f b6 c0             	movzbl %al,%eax
80102a1c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a20:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
80102a27:	e8 fc fd ff ff       	call   80102828 <outb>
  outb(0x1f5, (sector >> 16) & 0xff);
80102a2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102a2f:	c1 f8 10             	sar    $0x10,%eax
80102a32:	0f b6 c0             	movzbl %al,%eax
80102a35:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a39:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
80102a40:	e8 e3 fd ff ff       	call   80102828 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102a45:	8b 45 08             	mov    0x8(%ebp),%eax
80102a48:	8b 40 04             	mov    0x4(%eax),%eax
80102a4b:	83 e0 01             	and    $0x1,%eax
80102a4e:	c1 e0 04             	shl    $0x4,%eax
80102a51:	88 c2                	mov    %al,%dl
80102a53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102a56:	c1 f8 18             	sar    $0x18,%eax
80102a59:	83 e0 0f             	and    $0xf,%eax
80102a5c:	09 d0                	or     %edx,%eax
80102a5e:	83 c8 e0             	or     $0xffffffe0,%eax
80102a61:	0f b6 c0             	movzbl %al,%eax
80102a64:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a68:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102a6f:	e8 b4 fd ff ff       	call   80102828 <outb>
  if(b->flags & B_DIRTY){
80102a74:	8b 45 08             	mov    0x8(%ebp),%eax
80102a77:	8b 00                	mov    (%eax),%eax
80102a79:	83 e0 04             	and    $0x4,%eax
80102a7c:	85 c0                	test   %eax,%eax
80102a7e:	74 36                	je     80102ab6 <idestart+0x172>
    outb(0x1f7, write_cmd);
80102a80:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102a83:	0f b6 c0             	movzbl %al,%eax
80102a86:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a8a:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102a91:	e8 92 fd ff ff       	call   80102828 <outb>
    outsl(0x1f0, b->data, BSIZE/4);
80102a96:	8b 45 08             	mov    0x8(%ebp),%eax
80102a99:	83 c0 5c             	add    $0x5c,%eax
80102a9c:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102aa3:	00 
80102aa4:	89 44 24 04          	mov    %eax,0x4(%esp)
80102aa8:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102aaf:	e8 90 fd ff ff       	call   80102844 <outsl>
80102ab4:	eb 16                	jmp    80102acc <idestart+0x188>
  } else {
    outb(0x1f7, read_cmd);
80102ab6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ab9:	0f b6 c0             	movzbl %al,%eax
80102abc:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ac0:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102ac7:	e8 5c fd ff ff       	call   80102828 <outb>
  }
}
80102acc:	c9                   	leave  
80102acd:	c3                   	ret    

80102ace <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102ace:	55                   	push   %ebp
80102acf:	89 e5                	mov    %esp,%ebp
80102ad1:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102ad4:	c7 04 24 20 d9 10 80 	movl   $0x8010d920,(%esp)
80102adb:	e8 e7 2c 00 00       	call   801057c7 <acquire>

  if((b = idequeue) == 0){
80102ae0:	a1 54 d9 10 80       	mov    0x8010d954,%eax
80102ae5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102ae8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102aec:	75 11                	jne    80102aff <ideintr+0x31>
    release(&idelock);
80102aee:	c7 04 24 20 d9 10 80 	movl   $0x8010d920,(%esp)
80102af5:	e8 37 2d 00 00       	call   80105831 <release>
    return;
80102afa:	e9 90 00 00 00       	jmp    80102b8f <ideintr+0xc1>
  }
  idequeue = b->qnext;
80102aff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b02:	8b 40 58             	mov    0x58(%eax),%eax
80102b05:	a3 54 d9 10 80       	mov    %eax,0x8010d954

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b0d:	8b 00                	mov    (%eax),%eax
80102b0f:	83 e0 04             	and    $0x4,%eax
80102b12:	85 c0                	test   %eax,%eax
80102b14:	75 2e                	jne    80102b44 <ideintr+0x76>
80102b16:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102b1d:	e8 47 fd ff ff       	call   80102869 <idewait>
80102b22:	85 c0                	test   %eax,%eax
80102b24:	78 1e                	js     80102b44 <ideintr+0x76>
    insl(0x1f0, b->data, BSIZE/4);
80102b26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b29:	83 c0 5c             	add    $0x5c,%eax
80102b2c:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102b33:	00 
80102b34:	89 44 24 04          	mov    %eax,0x4(%esp)
80102b38:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102b3f:	e8 bf fc ff ff       	call   80102803 <insl>

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b47:	8b 00                	mov    (%eax),%eax
80102b49:	83 c8 02             	or     $0x2,%eax
80102b4c:	89 c2                	mov    %eax,%edx
80102b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b51:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b56:	8b 00                	mov    (%eax),%eax
80102b58:	83 e0 fb             	and    $0xfffffffb,%eax
80102b5b:	89 c2                	mov    %eax,%edx
80102b5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b60:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b65:	89 04 24             	mov    %eax,(%esp)
80102b68:	e8 31 24 00 00       	call   80104f9e <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102b6d:	a1 54 d9 10 80       	mov    0x8010d954,%eax
80102b72:	85 c0                	test   %eax,%eax
80102b74:	74 0d                	je     80102b83 <ideintr+0xb5>
    idestart(idequeue);
80102b76:	a1 54 d9 10 80       	mov    0x8010d954,%eax
80102b7b:	89 04 24             	mov    %eax,(%esp)
80102b7e:	e8 c1 fd ff ff       	call   80102944 <idestart>

  release(&idelock);
80102b83:	c7 04 24 20 d9 10 80 	movl   $0x8010d920,(%esp)
80102b8a:	e8 a2 2c 00 00       	call   80105831 <release>
}
80102b8f:	c9                   	leave  
80102b90:	c3                   	ret    

80102b91 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102b91:	55                   	push   %ebp
80102b92:	89 e5                	mov    %esp,%ebp
80102b94:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102b97:	8b 45 08             	mov    0x8(%ebp),%eax
80102b9a:	83 c0 0c             	add    $0xc,%eax
80102b9d:	89 04 24             	mov    %eax,(%esp)
80102ba0:	e8 9a 2b 00 00       	call   8010573f <holdingsleep>
80102ba5:	85 c0                	test   %eax,%eax
80102ba7:	75 0c                	jne    80102bb5 <iderw+0x24>
    panic("iderw: buf not locked");
80102ba9:	c7 04 24 2c 9f 10 80 	movl   $0x80109f2c,(%esp)
80102bb0:	e8 9f d9 ff ff       	call   80100554 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102bb5:	8b 45 08             	mov    0x8(%ebp),%eax
80102bb8:	8b 00                	mov    (%eax),%eax
80102bba:	83 e0 06             	and    $0x6,%eax
80102bbd:	83 f8 02             	cmp    $0x2,%eax
80102bc0:	75 0c                	jne    80102bce <iderw+0x3d>
    panic("iderw: nothing to do");
80102bc2:	c7 04 24 42 9f 10 80 	movl   $0x80109f42,(%esp)
80102bc9:	e8 86 d9 ff ff       	call   80100554 <panic>
  if(b->dev != 0 && !havedisk1)
80102bce:	8b 45 08             	mov    0x8(%ebp),%eax
80102bd1:	8b 40 04             	mov    0x4(%eax),%eax
80102bd4:	85 c0                	test   %eax,%eax
80102bd6:	74 15                	je     80102bed <iderw+0x5c>
80102bd8:	a1 58 d9 10 80       	mov    0x8010d958,%eax
80102bdd:	85 c0                	test   %eax,%eax
80102bdf:	75 0c                	jne    80102bed <iderw+0x5c>
    panic("iderw: ide disk 1 not present");
80102be1:	c7 04 24 57 9f 10 80 	movl   $0x80109f57,(%esp)
80102be8:	e8 67 d9 ff ff       	call   80100554 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102bed:	c7 04 24 20 d9 10 80 	movl   $0x8010d920,(%esp)
80102bf4:	e8 ce 2b 00 00       	call   801057c7 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102bf9:	8b 45 08             	mov    0x8(%ebp),%eax
80102bfc:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102c03:	c7 45 f4 54 d9 10 80 	movl   $0x8010d954,-0xc(%ebp)
80102c0a:	eb 0b                	jmp    80102c17 <iderw+0x86>
80102c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c0f:	8b 00                	mov    (%eax),%eax
80102c11:	83 c0 58             	add    $0x58,%eax
80102c14:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c1a:	8b 00                	mov    (%eax),%eax
80102c1c:	85 c0                	test   %eax,%eax
80102c1e:	75 ec                	jne    80102c0c <iderw+0x7b>
    ;
  *pp = b;
80102c20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c23:	8b 55 08             	mov    0x8(%ebp),%edx
80102c26:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102c28:	a1 54 d9 10 80       	mov    0x8010d954,%eax
80102c2d:	3b 45 08             	cmp    0x8(%ebp),%eax
80102c30:	75 0d                	jne    80102c3f <iderw+0xae>
    idestart(b);
80102c32:	8b 45 08             	mov    0x8(%ebp),%eax
80102c35:	89 04 24             	mov    %eax,(%esp)
80102c38:	e8 07 fd ff ff       	call   80102944 <idestart>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102c3d:	eb 15                	jmp    80102c54 <iderw+0xc3>
80102c3f:	eb 13                	jmp    80102c54 <iderw+0xc3>
    sleep(b, &idelock);
80102c41:	c7 44 24 04 20 d9 10 	movl   $0x8010d920,0x4(%esp)
80102c48:	80 
80102c49:	8b 45 08             	mov    0x8(%ebp),%eax
80102c4c:	89 04 24             	mov    %eax,(%esp)
80102c4f:	e8 73 22 00 00       	call   80104ec7 <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102c54:	8b 45 08             	mov    0x8(%ebp),%eax
80102c57:	8b 00                	mov    (%eax),%eax
80102c59:	83 e0 06             	and    $0x6,%eax
80102c5c:	83 f8 02             	cmp    $0x2,%eax
80102c5f:	75 e0                	jne    80102c41 <iderw+0xb0>
    sleep(b, &idelock);
  }


  release(&idelock);
80102c61:	c7 04 24 20 d9 10 80 	movl   $0x8010d920,(%esp)
80102c68:	e8 c4 2b 00 00       	call   80105831 <release>
}
80102c6d:	c9                   	leave  
80102c6e:	c3                   	ret    
	...

80102c70 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102c70:	55                   	push   %ebp
80102c71:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102c73:	a1 b4 5b 11 80       	mov    0x80115bb4,%eax
80102c78:	8b 55 08             	mov    0x8(%ebp),%edx
80102c7b:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102c7d:	a1 b4 5b 11 80       	mov    0x80115bb4,%eax
80102c82:	8b 40 10             	mov    0x10(%eax),%eax
}
80102c85:	5d                   	pop    %ebp
80102c86:	c3                   	ret    

80102c87 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102c87:	55                   	push   %ebp
80102c88:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102c8a:	a1 b4 5b 11 80       	mov    0x80115bb4,%eax
80102c8f:	8b 55 08             	mov    0x8(%ebp),%edx
80102c92:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102c94:	a1 b4 5b 11 80       	mov    0x80115bb4,%eax
80102c99:	8b 55 0c             	mov    0xc(%ebp),%edx
80102c9c:	89 50 10             	mov    %edx,0x10(%eax)
}
80102c9f:	5d                   	pop    %ebp
80102ca0:	c3                   	ret    

80102ca1 <ioapicinit>:

void
ioapicinit(void)
{
80102ca1:	55                   	push   %ebp
80102ca2:	89 e5                	mov    %esp,%ebp
80102ca4:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102ca7:	c7 05 b4 5b 11 80 00 	movl   $0xfec00000,0x80115bb4
80102cae:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102cb1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102cb8:	e8 b3 ff ff ff       	call   80102c70 <ioapicread>
80102cbd:	c1 e8 10             	shr    $0x10,%eax
80102cc0:	25 ff 00 00 00       	and    $0xff,%eax
80102cc5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102cc8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102ccf:	e8 9c ff ff ff       	call   80102c70 <ioapicread>
80102cd4:	c1 e8 18             	shr    $0x18,%eax
80102cd7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102cda:	a0 00 5d 11 80       	mov    0x80115d00,%al
80102cdf:	0f b6 c0             	movzbl %al,%eax
80102ce2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102ce5:	74 0c                	je     80102cf3 <ioapicinit+0x52>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102ce7:	c7 04 24 78 9f 10 80 	movl   $0x80109f78,(%esp)
80102cee:	e8 ce d6 ff ff       	call   801003c1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102cf3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102cfa:	eb 3d                	jmp    80102d39 <ioapicinit+0x98>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102cfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cff:	83 c0 20             	add    $0x20,%eax
80102d02:	0d 00 00 01 00       	or     $0x10000,%eax
80102d07:	89 c2                	mov    %eax,%edx
80102d09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d0c:	83 c0 08             	add    $0x8,%eax
80102d0f:	01 c0                	add    %eax,%eax
80102d11:	89 54 24 04          	mov    %edx,0x4(%esp)
80102d15:	89 04 24             	mov    %eax,(%esp)
80102d18:	e8 6a ff ff ff       	call   80102c87 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102d1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d20:	83 c0 08             	add    $0x8,%eax
80102d23:	01 c0                	add    %eax,%eax
80102d25:	40                   	inc    %eax
80102d26:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102d2d:	00 
80102d2e:	89 04 24             	mov    %eax,(%esp)
80102d31:	e8 51 ff ff ff       	call   80102c87 <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102d36:	ff 45 f4             	incl   -0xc(%ebp)
80102d39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d3c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102d3f:	7e bb                	jle    80102cfc <ioapicinit+0x5b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102d41:	c9                   	leave  
80102d42:	c3                   	ret    

80102d43 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102d43:	55                   	push   %ebp
80102d44:	89 e5                	mov    %esp,%ebp
80102d46:	83 ec 08             	sub    $0x8,%esp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102d49:	8b 45 08             	mov    0x8(%ebp),%eax
80102d4c:	83 c0 20             	add    $0x20,%eax
80102d4f:	89 c2                	mov    %eax,%edx
80102d51:	8b 45 08             	mov    0x8(%ebp),%eax
80102d54:	83 c0 08             	add    $0x8,%eax
80102d57:	01 c0                	add    %eax,%eax
80102d59:	89 54 24 04          	mov    %edx,0x4(%esp)
80102d5d:	89 04 24             	mov    %eax,(%esp)
80102d60:	e8 22 ff ff ff       	call   80102c87 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102d65:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d68:	c1 e0 18             	shl    $0x18,%eax
80102d6b:	8b 55 08             	mov    0x8(%ebp),%edx
80102d6e:	83 c2 08             	add    $0x8,%edx
80102d71:	01 d2                	add    %edx,%edx
80102d73:	42                   	inc    %edx
80102d74:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d78:	89 14 24             	mov    %edx,(%esp)
80102d7b:	e8 07 ff ff ff       	call   80102c87 <ioapicwrite>
}
80102d80:	c9                   	leave  
80102d81:	c3                   	ret    
	...

80102d84 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102d84:	55                   	push   %ebp
80102d85:	89 e5                	mov    %esp,%ebp
80102d87:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102d8a:	c7 44 24 04 aa 9f 10 	movl   $0x80109faa,0x4(%esp)
80102d91:	80 
80102d92:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
80102d99:	e8 08 2a 00 00       	call   801057a6 <initlock>
  kmem.use_lock = 0;
80102d9e:	c7 05 f4 5b 11 80 00 	movl   $0x0,0x80115bf4
80102da5:	00 00 00 
  freerange(vstart, vend);
80102da8:	8b 45 0c             	mov    0xc(%ebp),%eax
80102dab:	89 44 24 04          	mov    %eax,0x4(%esp)
80102daf:	8b 45 08             	mov    0x8(%ebp),%eax
80102db2:	89 04 24             	mov    %eax,(%esp)
80102db5:	e8 30 00 00 00       	call   80102dea <freerange>
}
80102dba:	c9                   	leave  
80102dbb:	c3                   	ret    

80102dbc <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102dbc:	55                   	push   %ebp
80102dbd:	89 e5                	mov    %esp,%ebp
80102dbf:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102dc2:	8b 45 0c             	mov    0xc(%ebp),%eax
80102dc5:	89 44 24 04          	mov    %eax,0x4(%esp)
80102dc9:	8b 45 08             	mov    0x8(%ebp),%eax
80102dcc:	89 04 24             	mov    %eax,(%esp)
80102dcf:	e8 16 00 00 00       	call   80102dea <freerange>
  kmem.use_lock = 1;
80102dd4:	c7 05 f4 5b 11 80 01 	movl   $0x1,0x80115bf4
80102ddb:	00 00 00 
  kmem.i = 0;
80102dde:	c7 05 fc 5b 11 80 00 	movl   $0x0,0x80115bfc
80102de5:	00 00 00 
}
80102de8:	c9                   	leave  
80102de9:	c3                   	ret    

80102dea <freerange>:

void
freerange(void *vstart, void *vend)
{
80102dea:	55                   	push   %ebp
80102deb:	89 e5                	mov    %esp,%ebp
80102ded:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102df0:	8b 45 08             	mov    0x8(%ebp),%eax
80102df3:	05 ff 0f 00 00       	add    $0xfff,%eax
80102df8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102dfd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102e00:	eb 12                	jmp    80102e14 <freerange+0x2a>
    kfree(p);
80102e02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e05:	89 04 24             	mov    %eax,(%esp)
80102e08:	e8 16 00 00 00       	call   80102e23 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102e0d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e17:	05 00 10 00 00       	add    $0x1000,%eax
80102e1c:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102e1f:	76 e1                	jbe    80102e02 <freerange+0x18>
    kfree(p);
}
80102e21:	c9                   	leave  
80102e22:	c3                   	ret    

80102e23 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102e23:	55                   	push   %ebp
80102e24:	89 e5                	mov    %esp,%ebp
80102e26:	83 ec 28             	sub    $0x28,%esp
  struct run *r;


  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102e29:	8b 45 08             	mov    0x8(%ebp),%eax
80102e2c:	25 ff 0f 00 00       	and    $0xfff,%eax
80102e31:	85 c0                	test   %eax,%eax
80102e33:	75 18                	jne    80102e4d <kfree+0x2a>
80102e35:	81 7d 08 70 8e 11 80 	cmpl   $0x80118e70,0x8(%ebp)
80102e3c:	72 0f                	jb     80102e4d <kfree+0x2a>
80102e3e:	8b 45 08             	mov    0x8(%ebp),%eax
80102e41:	05 00 00 00 80       	add    $0x80000000,%eax
80102e46:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102e4b:	76 0c                	jbe    80102e59 <kfree+0x36>
    panic("kfree");
80102e4d:	c7 04 24 af 9f 10 80 	movl   $0x80109faf,(%esp)
80102e54:	e8 fb d6 ff ff       	call   80100554 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102e59:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102e60:	00 
80102e61:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102e68:	00 
80102e69:	8b 45 08             	mov    0x8(%ebp),%eax
80102e6c:	89 04 24             	mov    %eax,(%esp)
80102e6f:	e8 b6 2b 00 00       	call   80105a2a <memset>

  if(kmem.use_lock){
80102e74:	a1 f4 5b 11 80       	mov    0x80115bf4,%eax
80102e79:	85 c0                	test   %eax,%eax
80102e7b:	74 59                	je     80102ed6 <kfree+0xb3>
    acquire(&kmem.lock);
80102e7d:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
80102e84:	e8 3e 29 00 00       	call   801057c7 <acquire>
    if(ticks > 0){
80102e89:	a1 40 8d 11 80       	mov    0x80118d40,%eax
80102e8e:	85 c0                	test   %eax,%eax
80102e90:	74 44                	je     80102ed6 <kfree+0xb3>
      int x = find(myproc()->cont->name);
80102e92:	e8 10 17 00 00       	call   801045a7 <myproc>
80102e97:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102e9d:	83 c0 1c             	add    $0x1c,%eax
80102ea0:	89 04 24             	mov    %eax,(%esp)
80102ea3:	e8 09 67 00 00       	call   801095b1 <find>
80102ea8:	89 45 f4             	mov    %eax,-0xc(%ebp)
      if(x >= 0){
80102eab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102eaf:	78 25                	js     80102ed6 <kfree+0xb3>
        reduce_curr_mem(1, x);
80102eb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102eb4:	89 44 24 04          	mov    %eax,0x4(%esp)
80102eb8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102ebf:	e8 df 69 00 00       	call   801098a3 <reduce_curr_mem>
        myproc()->usage--;
80102ec4:	e8 de 16 00 00       	call   801045a7 <myproc>
80102ec9:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80102ecf:	4a                   	dec    %edx
80102ed0:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
      }
    }
  }
  r = (struct run*)v;
80102ed6:	8b 45 08             	mov    0x8(%ebp),%eax
80102ed9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  r->next = kmem.freelist;
80102edc:	8b 15 f8 5b 11 80    	mov    0x80115bf8,%edx
80102ee2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ee5:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102ee7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102eea:	a3 f8 5b 11 80       	mov    %eax,0x80115bf8
  kmem.i--;
80102eef:	a1 fc 5b 11 80       	mov    0x80115bfc,%eax
80102ef4:	48                   	dec    %eax
80102ef5:	a3 fc 5b 11 80       	mov    %eax,0x80115bfc
  if(kmem.use_lock)
80102efa:	a1 f4 5b 11 80       	mov    0x80115bf4,%eax
80102eff:	85 c0                	test   %eax,%eax
80102f01:	74 0c                	je     80102f0f <kfree+0xec>
    release(&kmem.lock);
80102f03:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
80102f0a:	e8 22 29 00 00       	call   80105831 <release>
}
80102f0f:	c9                   	leave  
80102f10:	c3                   	ret    

80102f11 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102f11:	55                   	push   %ebp
80102f12:	89 e5                	mov    %esp,%ebp
80102f14:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock){
80102f17:	a1 f4 5b 11 80       	mov    0x80115bf4,%eax
80102f1c:	85 c0                	test   %eax,%eax
80102f1e:	74 0c                	je     80102f2c <kalloc+0x1b>
    acquire(&kmem.lock);
80102f20:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
80102f27:	e8 9b 28 00 00       	call   801057c7 <acquire>
  }
  r = kmem.freelist;
80102f2c:	a1 f8 5b 11 80       	mov    0x80115bf8,%eax
80102f31:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102f34:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102f38:	74 0a                	je     80102f44 <kalloc+0x33>
    kmem.freelist = r->next;
80102f3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f3d:	8b 00                	mov    (%eax),%eax
80102f3f:	a3 f8 5b 11 80       	mov    %eax,0x80115bf8
  kmem.i++;
80102f44:	a1 fc 5b 11 80       	mov    0x80115bfc,%eax
80102f49:	40                   	inc    %eax
80102f4a:	a3 fc 5b 11 80       	mov    %eax,0x80115bfc
  if((char*)r != 0){
80102f4f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102f53:	0f 84 84 00 00 00    	je     80102fdd <kalloc+0xcc>
    if(ticks > 0){
80102f59:	a1 40 8d 11 80       	mov    0x80118d40,%eax
80102f5e:	85 c0                	test   %eax,%eax
80102f60:	74 7b                	je     80102fdd <kalloc+0xcc>
      int x = find(myproc()->cont->name);
80102f62:	e8 40 16 00 00       	call   801045a7 <myproc>
80102f67:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102f6d:	83 c0 1c             	add    $0x1c,%eax
80102f70:	89 04 24             	mov    %eax,(%esp)
80102f73:	e8 39 66 00 00       	call   801095b1 <find>
80102f78:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(x >= 0){
80102f7b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102f7f:	78 5c                	js     80102fdd <kalloc+0xcc>
        myproc()->usage++;
80102f81:	e8 21 16 00 00       	call   801045a7 <myproc>
80102f86:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80102f8c:	42                   	inc    %edx
80102f8d:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
        int before = get_curr_mem(x);
80102f93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f96:	89 04 24             	mov    %eax,(%esp)
80102f99:	e8 85 67 00 00       	call   80109723 <get_curr_mem>
80102f9e:	89 45 ec             	mov    %eax,-0x14(%ebp)
        set_curr_mem(1, x);
80102fa1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fa4:	89 44 24 04          	mov    %eax,0x4(%esp)
80102fa8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102faf:	e8 7c 68 00 00       	call   80109830 <set_curr_mem>
        int after = get_curr_mem(x);
80102fb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fb7:	89 04 24             	mov    %eax,(%esp)
80102fba:	e8 64 67 00 00       	call   80109723 <get_curr_mem>
80102fbf:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if(before == after){
80102fc2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fc5:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80102fc8:	75 13                	jne    80102fdd <kalloc+0xcc>
          cstop_container_helper(myproc()->cont);
80102fca:	e8 d8 15 00 00       	call   801045a7 <myproc>
80102fcf:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102fd5:	89 04 24             	mov    %eax,(%esp)
80102fd8:	e8 23 22 00 00       	call   80105200 <cstop_container_helper>
        }
      }
   }
  }
  if(kmem.use_lock)
80102fdd:	a1 f4 5b 11 80       	mov    0x80115bf4,%eax
80102fe2:	85 c0                	test   %eax,%eax
80102fe4:	74 0c                	je     80102ff2 <kalloc+0xe1>
    release(&kmem.lock);
80102fe6:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
80102fed:	e8 3f 28 00 00       	call   80105831 <release>
  return (char*)r;
80102ff2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102ff5:	c9                   	leave  
80102ff6:	c3                   	ret    

80102ff7 <mem_usage>:

int mem_usage(void){
80102ff7:	55                   	push   %ebp
80102ff8:	89 e5                	mov    %esp,%ebp
  return kmem.i;
80102ffa:	a1 fc 5b 11 80       	mov    0x80115bfc,%eax
}
80102fff:	5d                   	pop    %ebp
80103000:	c3                   	ret    

80103001 <mem_avail>:

int mem_avail(void){
80103001:	55                   	push   %ebp
80103002:	89 e5                	mov    %esp,%ebp
80103004:	83 ec 10             	sub    $0x10,%esp
  int freebytes = ((P2V(4*1024*1024) - (void*)end) + (P2V(PHYSTOP) - P2V(4*1024*1024)))/4096;
80103007:	b8 70 8e 11 80       	mov    $0x80118e70,%eax
8010300c:	ba 00 00 00 8e       	mov    $0x8e000000,%edx
80103011:	29 c2                	sub    %eax,%edx
80103013:	89 d0                	mov    %edx,%eax
80103015:	85 c0                	test   %eax,%eax
80103017:	79 05                	jns    8010301e <mem_avail+0x1d>
80103019:	05 ff 0f 00 00       	add    $0xfff,%eax
8010301e:	c1 f8 0c             	sar    $0xc,%eax
80103021:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return freebytes;
80103024:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103027:	c9                   	leave  
80103028:	c3                   	ret    
80103029:	00 00                	add    %al,(%eax)
	...

8010302c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010302c:	55                   	push   %ebp
8010302d:	89 e5                	mov    %esp,%ebp
8010302f:	83 ec 14             	sub    $0x14,%esp
80103032:	8b 45 08             	mov    0x8(%ebp),%eax
80103035:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103039:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010303c:	89 c2                	mov    %eax,%edx
8010303e:	ec                   	in     (%dx),%al
8010303f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103042:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80103045:	c9                   	leave  
80103046:	c3                   	ret    

80103047 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80103047:	55                   	push   %ebp
80103048:	89 e5                	mov    %esp,%ebp
8010304a:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
8010304d:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80103054:	e8 d3 ff ff ff       	call   8010302c <inb>
80103059:	0f b6 c0             	movzbl %al,%eax
8010305c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
8010305f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103062:	83 e0 01             	and    $0x1,%eax
80103065:	85 c0                	test   %eax,%eax
80103067:	75 0a                	jne    80103073 <kbdgetc+0x2c>
    return -1;
80103069:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010306e:	e9 21 01 00 00       	jmp    80103194 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80103073:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
8010307a:	e8 ad ff ff ff       	call   8010302c <inb>
8010307f:	0f b6 c0             	movzbl %al,%eax
80103082:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80103085:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
8010308c:	75 17                	jne    801030a5 <kbdgetc+0x5e>
    shift |= E0ESC;
8010308e:	a1 5c d9 10 80       	mov    0x8010d95c,%eax
80103093:	83 c8 40             	or     $0x40,%eax
80103096:	a3 5c d9 10 80       	mov    %eax,0x8010d95c
    return 0;
8010309b:	b8 00 00 00 00       	mov    $0x0,%eax
801030a0:	e9 ef 00 00 00       	jmp    80103194 <kbdgetc+0x14d>
  } else if(data & 0x80){
801030a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801030a8:	25 80 00 00 00       	and    $0x80,%eax
801030ad:	85 c0                	test   %eax,%eax
801030af:	74 44                	je     801030f5 <kbdgetc+0xae>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
801030b1:	a1 5c d9 10 80       	mov    0x8010d95c,%eax
801030b6:	83 e0 40             	and    $0x40,%eax
801030b9:	85 c0                	test   %eax,%eax
801030bb:	75 08                	jne    801030c5 <kbdgetc+0x7e>
801030bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801030c0:	83 e0 7f             	and    $0x7f,%eax
801030c3:	eb 03                	jmp    801030c8 <kbdgetc+0x81>
801030c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801030c8:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
801030cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801030ce:	05 20 b0 10 80       	add    $0x8010b020,%eax
801030d3:	8a 00                	mov    (%eax),%al
801030d5:	83 c8 40             	or     $0x40,%eax
801030d8:	0f b6 c0             	movzbl %al,%eax
801030db:	f7 d0                	not    %eax
801030dd:	89 c2                	mov    %eax,%edx
801030df:	a1 5c d9 10 80       	mov    0x8010d95c,%eax
801030e4:	21 d0                	and    %edx,%eax
801030e6:	a3 5c d9 10 80       	mov    %eax,0x8010d95c
    return 0;
801030eb:	b8 00 00 00 00       	mov    $0x0,%eax
801030f0:	e9 9f 00 00 00       	jmp    80103194 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
801030f5:	a1 5c d9 10 80       	mov    0x8010d95c,%eax
801030fa:	83 e0 40             	and    $0x40,%eax
801030fd:	85 c0                	test   %eax,%eax
801030ff:	74 14                	je     80103115 <kbdgetc+0xce>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80103101:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80103108:	a1 5c d9 10 80       	mov    0x8010d95c,%eax
8010310d:	83 e0 bf             	and    $0xffffffbf,%eax
80103110:	a3 5c d9 10 80       	mov    %eax,0x8010d95c
  }

  shift |= shiftcode[data];
80103115:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103118:	05 20 b0 10 80       	add    $0x8010b020,%eax
8010311d:	8a 00                	mov    (%eax),%al
8010311f:	0f b6 d0             	movzbl %al,%edx
80103122:	a1 5c d9 10 80       	mov    0x8010d95c,%eax
80103127:	09 d0                	or     %edx,%eax
80103129:	a3 5c d9 10 80       	mov    %eax,0x8010d95c
  shift ^= togglecode[data];
8010312e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103131:	05 20 b1 10 80       	add    $0x8010b120,%eax
80103136:	8a 00                	mov    (%eax),%al
80103138:	0f b6 d0             	movzbl %al,%edx
8010313b:	a1 5c d9 10 80       	mov    0x8010d95c,%eax
80103140:	31 d0                	xor    %edx,%eax
80103142:	a3 5c d9 10 80       	mov    %eax,0x8010d95c
  c = charcode[shift & (CTL | SHIFT)][data];
80103147:	a1 5c d9 10 80       	mov    0x8010d95c,%eax
8010314c:	83 e0 03             	and    $0x3,%eax
8010314f:	8b 14 85 20 b5 10 80 	mov    -0x7fef4ae0(,%eax,4),%edx
80103156:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103159:	01 d0                	add    %edx,%eax
8010315b:	8a 00                	mov    (%eax),%al
8010315d:	0f b6 c0             	movzbl %al,%eax
80103160:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80103163:	a1 5c d9 10 80       	mov    0x8010d95c,%eax
80103168:	83 e0 08             	and    $0x8,%eax
8010316b:	85 c0                	test   %eax,%eax
8010316d:	74 22                	je     80103191 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
8010316f:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80103173:	76 0c                	jbe    80103181 <kbdgetc+0x13a>
80103175:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80103179:	77 06                	ja     80103181 <kbdgetc+0x13a>
      c += 'A' - 'a';
8010317b:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
8010317f:	eb 10                	jmp    80103191 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80103181:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80103185:	76 0a                	jbe    80103191 <kbdgetc+0x14a>
80103187:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
8010318b:	77 04                	ja     80103191 <kbdgetc+0x14a>
      c += 'a' - 'A';
8010318d:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80103191:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103194:	c9                   	leave  
80103195:	c3                   	ret    

80103196 <kbdintr>:

void
kbdintr(void)
{
80103196:	55                   	push   %ebp
80103197:	89 e5                	mov    %esp,%ebp
80103199:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
8010319c:	c7 04 24 47 30 10 80 	movl   $0x80103047,(%esp)
801031a3:	e8 4d d6 ff ff       	call   801007f5 <consoleintr>
}
801031a8:	c9                   	leave  
801031a9:	c3                   	ret    
	...

801031ac <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801031ac:	55                   	push   %ebp
801031ad:	89 e5                	mov    %esp,%ebp
801031af:	83 ec 14             	sub    $0x14,%esp
801031b2:	8b 45 08             	mov    0x8(%ebp),%eax
801031b5:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801031b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031bc:	89 c2                	mov    %eax,%edx
801031be:	ec                   	in     (%dx),%al
801031bf:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801031c2:	8a 45 ff             	mov    -0x1(%ebp),%al
}
801031c5:	c9                   	leave  
801031c6:	c3                   	ret    

801031c7 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801031c7:	55                   	push   %ebp
801031c8:	89 e5                	mov    %esp,%ebp
801031ca:	83 ec 08             	sub    $0x8,%esp
801031cd:	8b 45 08             	mov    0x8(%ebp),%eax
801031d0:	8b 55 0c             	mov    0xc(%ebp),%edx
801031d3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801031d7:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801031da:	8a 45 f8             	mov    -0x8(%ebp),%al
801031dd:	8b 55 fc             	mov    -0x4(%ebp),%edx
801031e0:	ee                   	out    %al,(%dx)
}
801031e1:	c9                   	leave  
801031e2:	c3                   	ret    

801031e3 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
801031e3:	55                   	push   %ebp
801031e4:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801031e6:	a1 00 5c 11 80       	mov    0x80115c00,%eax
801031eb:	8b 55 08             	mov    0x8(%ebp),%edx
801031ee:	c1 e2 02             	shl    $0x2,%edx
801031f1:	01 c2                	add    %eax,%edx
801031f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801031f6:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801031f8:	a1 00 5c 11 80       	mov    0x80115c00,%eax
801031fd:	83 c0 20             	add    $0x20,%eax
80103200:	8b 00                	mov    (%eax),%eax
}
80103202:	5d                   	pop    %ebp
80103203:	c3                   	ret    

80103204 <lapicinit>:

void
lapicinit(void)
{
80103204:	55                   	push   %ebp
80103205:	89 e5                	mov    %esp,%ebp
80103207:	83 ec 08             	sub    $0x8,%esp
  if(!lapic)
8010320a:	a1 00 5c 11 80       	mov    0x80115c00,%eax
8010320f:	85 c0                	test   %eax,%eax
80103211:	75 05                	jne    80103218 <lapicinit+0x14>
    return;
80103213:	e9 43 01 00 00       	jmp    8010335b <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80103218:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
8010321f:	00 
80103220:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80103227:	e8 b7 ff ff ff       	call   801031e3 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
8010322c:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80103233:	00 
80103234:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
8010323b:	e8 a3 ff ff ff       	call   801031e3 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80103240:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80103247:	00 
80103248:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010324f:	e8 8f ff ff ff       	call   801031e3 <lapicw>
  lapicw(TICR, 10000000);
80103254:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
8010325b:	00 
8010325c:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80103263:	e8 7b ff ff ff       	call   801031e3 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80103268:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
8010326f:	00 
80103270:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80103277:	e8 67 ff ff ff       	call   801031e3 <lapicw>
  lapicw(LINT1, MASKED);
8010327c:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103283:	00 
80103284:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
8010328b:	e8 53 ff ff ff       	call   801031e3 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80103290:	a1 00 5c 11 80       	mov    0x80115c00,%eax
80103295:	83 c0 30             	add    $0x30,%eax
80103298:	8b 00                	mov    (%eax),%eax
8010329a:	c1 e8 10             	shr    $0x10,%eax
8010329d:	0f b6 c0             	movzbl %al,%eax
801032a0:	83 f8 03             	cmp    $0x3,%eax
801032a3:	76 14                	jbe    801032b9 <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
801032a5:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801032ac:	00 
801032ad:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
801032b4:	e8 2a ff ff ff       	call   801031e3 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
801032b9:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
801032c0:	00 
801032c1:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
801032c8:	e8 16 ff ff ff       	call   801031e3 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
801032cd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801032d4:	00 
801032d5:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
801032dc:	e8 02 ff ff ff       	call   801031e3 <lapicw>
  lapicw(ESR, 0);
801032e1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801032e8:	00 
801032e9:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
801032f0:	e8 ee fe ff ff       	call   801031e3 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
801032f5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801032fc:	00 
801032fd:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103304:	e8 da fe ff ff       	call   801031e3 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103309:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103310:	00 
80103311:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103318:	e8 c6 fe ff ff       	call   801031e3 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
8010331d:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80103324:	00 
80103325:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010332c:	e8 b2 fe ff ff       	call   801031e3 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80103331:	90                   	nop
80103332:	a1 00 5c 11 80       	mov    0x80115c00,%eax
80103337:	05 00 03 00 00       	add    $0x300,%eax
8010333c:	8b 00                	mov    (%eax),%eax
8010333e:	25 00 10 00 00       	and    $0x1000,%eax
80103343:	85 c0                	test   %eax,%eax
80103345:	75 eb                	jne    80103332 <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80103347:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010334e:	00 
8010334f:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103356:	e8 88 fe ff ff       	call   801031e3 <lapicw>
}
8010335b:	c9                   	leave  
8010335c:	c3                   	ret    

8010335d <lapicid>:

int
lapicid(void)
{
8010335d:	55                   	push   %ebp
8010335e:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80103360:	a1 00 5c 11 80       	mov    0x80115c00,%eax
80103365:	85 c0                	test   %eax,%eax
80103367:	75 07                	jne    80103370 <lapicid+0x13>
    return 0;
80103369:	b8 00 00 00 00       	mov    $0x0,%eax
8010336e:	eb 0d                	jmp    8010337d <lapicid+0x20>
  return lapic[ID] >> 24;
80103370:	a1 00 5c 11 80       	mov    0x80115c00,%eax
80103375:	83 c0 20             	add    $0x20,%eax
80103378:	8b 00                	mov    (%eax),%eax
8010337a:	c1 e8 18             	shr    $0x18,%eax
}
8010337d:	5d                   	pop    %ebp
8010337e:	c3                   	ret    

8010337f <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
8010337f:	55                   	push   %ebp
80103380:	89 e5                	mov    %esp,%ebp
80103382:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80103385:	a1 00 5c 11 80       	mov    0x80115c00,%eax
8010338a:	85 c0                	test   %eax,%eax
8010338c:	74 14                	je     801033a2 <lapiceoi+0x23>
    lapicw(EOI, 0);
8010338e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103395:	00 
80103396:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
8010339d:	e8 41 fe ff ff       	call   801031e3 <lapicw>
}
801033a2:	c9                   	leave  
801033a3:	c3                   	ret    

801033a4 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
801033a4:	55                   	push   %ebp
801033a5:	89 e5                	mov    %esp,%ebp
}
801033a7:	5d                   	pop    %ebp
801033a8:	c3                   	ret    

801033a9 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
801033a9:	55                   	push   %ebp
801033aa:	89 e5                	mov    %esp,%ebp
801033ac:	83 ec 1c             	sub    $0x1c,%esp
801033af:	8b 45 08             	mov    0x8(%ebp),%eax
801033b2:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
801033b5:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
801033bc:	00 
801033bd:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
801033c4:	e8 fe fd ff ff       	call   801031c7 <outb>
  outb(CMOS_PORT+1, 0x0A);
801033c9:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
801033d0:	00 
801033d1:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
801033d8:	e8 ea fd ff ff       	call   801031c7 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
801033dd:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
801033e4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801033e7:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
801033ec:	8b 45 f8             	mov    -0x8(%ebp),%eax
801033ef:	8d 50 02             	lea    0x2(%eax),%edx
801033f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801033f5:	c1 e8 04             	shr    $0x4,%eax
801033f8:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
801033fb:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801033ff:	c1 e0 18             	shl    $0x18,%eax
80103402:	89 44 24 04          	mov    %eax,0x4(%esp)
80103406:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
8010340d:	e8 d1 fd ff ff       	call   801031e3 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103412:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80103419:	00 
8010341a:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103421:	e8 bd fd ff ff       	call   801031e3 <lapicw>
  microdelay(200);
80103426:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010342d:	e8 72 ff ff ff       	call   801033a4 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
80103432:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80103439:	00 
8010343a:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103441:	e8 9d fd ff ff       	call   801031e3 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103446:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
8010344d:	e8 52 ff ff ff       	call   801033a4 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103452:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103459:	eb 3f                	jmp    8010349a <lapicstartap+0xf1>
    lapicw(ICRHI, apicid<<24);
8010345b:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010345f:	c1 e0 18             	shl    $0x18,%eax
80103462:	89 44 24 04          	mov    %eax,0x4(%esp)
80103466:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
8010346d:	e8 71 fd ff ff       	call   801031e3 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80103472:	8b 45 0c             	mov    0xc(%ebp),%eax
80103475:	c1 e8 0c             	shr    $0xc,%eax
80103478:	80 cc 06             	or     $0x6,%ah
8010347b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010347f:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103486:	e8 58 fd ff ff       	call   801031e3 <lapicw>
    microdelay(200);
8010348b:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103492:	e8 0d ff ff ff       	call   801033a4 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103497:	ff 45 fc             	incl   -0x4(%ebp)
8010349a:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010349e:	7e bb                	jle    8010345b <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
801034a0:	c9                   	leave  
801034a1:	c3                   	ret    

801034a2 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
801034a2:	55                   	push   %ebp
801034a3:	89 e5                	mov    %esp,%ebp
801034a5:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
801034a8:	8b 45 08             	mov    0x8(%ebp),%eax
801034ab:	0f b6 c0             	movzbl %al,%eax
801034ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801034b2:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
801034b9:	e8 09 fd ff ff       	call   801031c7 <outb>
  microdelay(200);
801034be:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801034c5:	e8 da fe ff ff       	call   801033a4 <microdelay>

  return inb(CMOS_RETURN);
801034ca:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
801034d1:	e8 d6 fc ff ff       	call   801031ac <inb>
801034d6:	0f b6 c0             	movzbl %al,%eax
}
801034d9:	c9                   	leave  
801034da:	c3                   	ret    

801034db <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
801034db:	55                   	push   %ebp
801034dc:	89 e5                	mov    %esp,%ebp
801034de:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
801034e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801034e8:	e8 b5 ff ff ff       	call   801034a2 <cmos_read>
801034ed:	8b 55 08             	mov    0x8(%ebp),%edx
801034f0:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
801034f2:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801034f9:	e8 a4 ff ff ff       	call   801034a2 <cmos_read>
801034fe:	8b 55 08             	mov    0x8(%ebp),%edx
80103501:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103504:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
8010350b:	e8 92 ff ff ff       	call   801034a2 <cmos_read>
80103510:	8b 55 08             	mov    0x8(%ebp),%edx
80103513:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103516:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
8010351d:	e8 80 ff ff ff       	call   801034a2 <cmos_read>
80103522:	8b 55 08             	mov    0x8(%ebp),%edx
80103525:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103528:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010352f:	e8 6e ff ff ff       	call   801034a2 <cmos_read>
80103534:	8b 55 08             	mov    0x8(%ebp),%edx
80103537:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
8010353a:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
80103541:	e8 5c ff ff ff       	call   801034a2 <cmos_read>
80103546:	8b 55 08             	mov    0x8(%ebp),%edx
80103549:	89 42 14             	mov    %eax,0x14(%edx)
}
8010354c:	c9                   	leave  
8010354d:	c3                   	ret    

8010354e <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
8010354e:	55                   	push   %ebp
8010354f:	89 e5                	mov    %esp,%ebp
80103551:	57                   	push   %edi
80103552:	56                   	push   %esi
80103553:	53                   	push   %ebx
80103554:	83 ec 5c             	sub    $0x5c,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103557:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
8010355e:	e8 3f ff ff ff       	call   801034a2 <cmos_read>
80103563:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103566:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103569:	83 e0 04             	and    $0x4,%eax
8010356c:	85 c0                	test   %eax,%eax
8010356e:	0f 94 c0             	sete   %al
80103571:	0f b6 c0             	movzbl %al,%eax
80103574:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80103577:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010357a:	89 04 24             	mov    %eax,(%esp)
8010357d:	e8 59 ff ff ff       	call   801034db <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80103582:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80103589:	e8 14 ff ff ff       	call   801034a2 <cmos_read>
8010358e:	25 80 00 00 00       	and    $0x80,%eax
80103593:	85 c0                	test   %eax,%eax
80103595:	74 02                	je     80103599 <cmostime+0x4b>
        continue;
80103597:	eb 36                	jmp    801035cf <cmostime+0x81>
    fill_rtcdate(&t2);
80103599:	8d 45 b0             	lea    -0x50(%ebp),%eax
8010359c:	89 04 24             	mov    %eax,(%esp)
8010359f:	e8 37 ff ff ff       	call   801034db <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801035a4:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
801035ab:	00 
801035ac:	8d 45 b0             	lea    -0x50(%ebp),%eax
801035af:	89 44 24 04          	mov    %eax,0x4(%esp)
801035b3:	8d 45 c8             	lea    -0x38(%ebp),%eax
801035b6:	89 04 24             	mov    %eax,(%esp)
801035b9:	e8 e3 24 00 00       	call   80105aa1 <memcmp>
801035be:	85 c0                	test   %eax,%eax
801035c0:	75 0d                	jne    801035cf <cmostime+0x81>
      break;
801035c2:	90                   	nop
  }

  // convert
  if(bcd) {
801035c3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801035c7:	0f 84 ac 00 00 00    	je     80103679 <cmostime+0x12b>
801035cd:	eb 02                	jmp    801035d1 <cmostime+0x83>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
801035cf:	eb a6                	jmp    80103577 <cmostime+0x29>

  // convert
  if(bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801035d1:	8b 45 c8             	mov    -0x38(%ebp),%eax
801035d4:	c1 e8 04             	shr    $0x4,%eax
801035d7:	89 c2                	mov    %eax,%edx
801035d9:	89 d0                	mov    %edx,%eax
801035db:	c1 e0 02             	shl    $0x2,%eax
801035de:	01 d0                	add    %edx,%eax
801035e0:	01 c0                	add    %eax,%eax
801035e2:	8b 55 c8             	mov    -0x38(%ebp),%edx
801035e5:	83 e2 0f             	and    $0xf,%edx
801035e8:	01 d0                	add    %edx,%eax
801035ea:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(minute);
801035ed:	8b 45 cc             	mov    -0x34(%ebp),%eax
801035f0:	c1 e8 04             	shr    $0x4,%eax
801035f3:	89 c2                	mov    %eax,%edx
801035f5:	89 d0                	mov    %edx,%eax
801035f7:	c1 e0 02             	shl    $0x2,%eax
801035fa:	01 d0                	add    %edx,%eax
801035fc:	01 c0                	add    %eax,%eax
801035fe:	8b 55 cc             	mov    -0x34(%ebp),%edx
80103601:	83 e2 0f             	and    $0xf,%edx
80103604:	01 d0                	add    %edx,%eax
80103606:	89 45 cc             	mov    %eax,-0x34(%ebp)
    CONV(hour  );
80103609:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010360c:	c1 e8 04             	shr    $0x4,%eax
8010360f:	89 c2                	mov    %eax,%edx
80103611:	89 d0                	mov    %edx,%eax
80103613:	c1 e0 02             	shl    $0x2,%eax
80103616:	01 d0                	add    %edx,%eax
80103618:	01 c0                	add    %eax,%eax
8010361a:	8b 55 d0             	mov    -0x30(%ebp),%edx
8010361d:	83 e2 0f             	and    $0xf,%edx
80103620:	01 d0                	add    %edx,%eax
80103622:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(day   );
80103625:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80103628:	c1 e8 04             	shr    $0x4,%eax
8010362b:	89 c2                	mov    %eax,%edx
8010362d:	89 d0                	mov    %edx,%eax
8010362f:	c1 e0 02             	shl    $0x2,%eax
80103632:	01 d0                	add    %edx,%eax
80103634:	01 c0                	add    %eax,%eax
80103636:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80103639:	83 e2 0f             	and    $0xf,%edx
8010363c:	01 d0                	add    %edx,%eax
8010363e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(month );
80103641:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103644:	c1 e8 04             	shr    $0x4,%eax
80103647:	89 c2                	mov    %eax,%edx
80103649:	89 d0                	mov    %edx,%eax
8010364b:	c1 e0 02             	shl    $0x2,%eax
8010364e:	01 d0                	add    %edx,%eax
80103650:	01 c0                	add    %eax,%eax
80103652:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103655:	83 e2 0f             	and    $0xf,%edx
80103658:	01 d0                	add    %edx,%eax
8010365a:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(year  );
8010365d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103660:	c1 e8 04             	shr    $0x4,%eax
80103663:	89 c2                	mov    %eax,%edx
80103665:	89 d0                	mov    %edx,%eax
80103667:	c1 e0 02             	shl    $0x2,%eax
8010366a:	01 d0                	add    %edx,%eax
8010366c:	01 c0                	add    %eax,%eax
8010366e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103671:	83 e2 0f             	and    $0xf,%edx
80103674:	01 d0                	add    %edx,%eax
80103676:	89 45 dc             	mov    %eax,-0x24(%ebp)
#undef     CONV
  }

  *r = t1;
80103679:	8b 45 08             	mov    0x8(%ebp),%eax
8010367c:	89 c2                	mov    %eax,%edx
8010367e:	8d 5d c8             	lea    -0x38(%ebp),%ebx
80103681:	b8 06 00 00 00       	mov    $0x6,%eax
80103686:	89 d7                	mov    %edx,%edi
80103688:	89 de                	mov    %ebx,%esi
8010368a:	89 c1                	mov    %eax,%ecx
8010368c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  r->year += 2000;
8010368e:	8b 45 08             	mov    0x8(%ebp),%eax
80103691:	8b 40 14             	mov    0x14(%eax),%eax
80103694:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
8010369a:	8b 45 08             	mov    0x8(%ebp),%eax
8010369d:	89 50 14             	mov    %edx,0x14(%eax)
}
801036a0:	83 c4 5c             	add    $0x5c,%esp
801036a3:	5b                   	pop    %ebx
801036a4:	5e                   	pop    %esi
801036a5:	5f                   	pop    %edi
801036a6:	5d                   	pop    %ebp
801036a7:	c3                   	ret    

801036a8 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
801036a8:	55                   	push   %ebp
801036a9:	89 e5                	mov    %esp,%ebp
801036ab:	83 ec 48             	sub    $0x48,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801036ae:	c7 44 24 04 b5 9f 10 	movl   $0x80109fb5,0x4(%esp)
801036b5:	80 
801036b6:	c7 04 24 20 5c 11 80 	movl   $0x80115c20,(%esp)
801036bd:	e8 e4 20 00 00       	call   801057a6 <initlock>
  readsb(dev, &sb);
801036c2:	8d 45 d0             	lea    -0x30(%ebp),%eax
801036c5:	89 44 24 04          	mov    %eax,0x4(%esp)
801036c9:	8b 45 08             	mov    0x8(%ebp),%eax
801036cc:	89 04 24             	mov    %eax,(%esp)
801036cf:	e8 ec dd ff ff       	call   801014c0 <readsb>
  log.start = sb.logstart;
801036d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801036d7:	a3 54 5c 11 80       	mov    %eax,0x80115c54
  log.size = sb.nlog;
801036dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
801036df:	a3 58 5c 11 80       	mov    %eax,0x80115c58
  log.dev = dev;
801036e4:	8b 45 08             	mov    0x8(%ebp),%eax
801036e7:	a3 64 5c 11 80       	mov    %eax,0x80115c64
  recover_from_log();
801036ec:	e8 95 01 00 00       	call   80103886 <recover_from_log>
}
801036f1:	c9                   	leave  
801036f2:	c3                   	ret    

801036f3 <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
801036f3:	55                   	push   %ebp
801036f4:	89 e5                	mov    %esp,%ebp
801036f6:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801036f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103700:	e9 89 00 00 00       	jmp    8010378e <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103705:	8b 15 54 5c 11 80    	mov    0x80115c54,%edx
8010370b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010370e:	01 d0                	add    %edx,%eax
80103710:	40                   	inc    %eax
80103711:	89 c2                	mov    %eax,%edx
80103713:	a1 64 5c 11 80       	mov    0x80115c64,%eax
80103718:	89 54 24 04          	mov    %edx,0x4(%esp)
8010371c:	89 04 24             	mov    %eax,(%esp)
8010371f:	e8 91 ca ff ff       	call   801001b5 <bread>
80103724:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103727:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010372a:	83 c0 10             	add    $0x10,%eax
8010372d:	8b 04 85 2c 5c 11 80 	mov    -0x7feea3d4(,%eax,4),%eax
80103734:	89 c2                	mov    %eax,%edx
80103736:	a1 64 5c 11 80       	mov    0x80115c64,%eax
8010373b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010373f:	89 04 24             	mov    %eax,(%esp)
80103742:	e8 6e ca ff ff       	call   801001b5 <bread>
80103747:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010374a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010374d:	8d 50 5c             	lea    0x5c(%eax),%edx
80103750:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103753:	83 c0 5c             	add    $0x5c,%eax
80103756:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010375d:	00 
8010375e:	89 54 24 04          	mov    %edx,0x4(%esp)
80103762:	89 04 24             	mov    %eax,(%esp)
80103765:	e8 89 23 00 00       	call   80105af3 <memmove>
    bwrite(dbuf);  // write dst to disk
8010376a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010376d:	89 04 24             	mov    %eax,(%esp)
80103770:	e8 77 ca ff ff       	call   801001ec <bwrite>
    brelse(lbuf);
80103775:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103778:	89 04 24             	mov    %eax,(%esp)
8010377b:	e8 ac ca ff ff       	call   8010022c <brelse>
    brelse(dbuf);
80103780:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103783:	89 04 24             	mov    %eax,(%esp)
80103786:	e8 a1 ca ff ff       	call   8010022c <brelse>
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010378b:	ff 45 f4             	incl   -0xc(%ebp)
8010378e:	a1 68 5c 11 80       	mov    0x80115c68,%eax
80103793:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103796:	0f 8f 69 ff ff ff    	jg     80103705 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf);
    brelse(dbuf);
  }
}
8010379c:	c9                   	leave  
8010379d:	c3                   	ret    

8010379e <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010379e:	55                   	push   %ebp
8010379f:	89 e5                	mov    %esp,%ebp
801037a1:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801037a4:	a1 54 5c 11 80       	mov    0x80115c54,%eax
801037a9:	89 c2                	mov    %eax,%edx
801037ab:	a1 64 5c 11 80       	mov    0x80115c64,%eax
801037b0:	89 54 24 04          	mov    %edx,0x4(%esp)
801037b4:	89 04 24             	mov    %eax,(%esp)
801037b7:	e8 f9 c9 ff ff       	call   801001b5 <bread>
801037bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801037bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037c2:	83 c0 5c             	add    $0x5c,%eax
801037c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801037c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801037cb:	8b 00                	mov    (%eax),%eax
801037cd:	a3 68 5c 11 80       	mov    %eax,0x80115c68
  for (i = 0; i < log.lh.n; i++) {
801037d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037d9:	eb 1a                	jmp    801037f5 <read_head+0x57>
    log.lh.block[i] = lh->block[i];
801037db:	8b 45 ec             	mov    -0x14(%ebp),%eax
801037de:	8b 55 f4             	mov    -0xc(%ebp),%edx
801037e1:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801037e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801037e8:	83 c2 10             	add    $0x10,%edx
801037eb:	89 04 95 2c 5c 11 80 	mov    %eax,-0x7feea3d4(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801037f2:	ff 45 f4             	incl   -0xc(%ebp)
801037f5:	a1 68 5c 11 80       	mov    0x80115c68,%eax
801037fa:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037fd:	7f dc                	jg     801037db <read_head+0x3d>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
801037ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103802:	89 04 24             	mov    %eax,(%esp)
80103805:	e8 22 ca ff ff       	call   8010022c <brelse>
}
8010380a:	c9                   	leave  
8010380b:	c3                   	ret    

8010380c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010380c:	55                   	push   %ebp
8010380d:	89 e5                	mov    %esp,%ebp
8010380f:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103812:	a1 54 5c 11 80       	mov    0x80115c54,%eax
80103817:	89 c2                	mov    %eax,%edx
80103819:	a1 64 5c 11 80       	mov    0x80115c64,%eax
8010381e:	89 54 24 04          	mov    %edx,0x4(%esp)
80103822:	89 04 24             	mov    %eax,(%esp)
80103825:	e8 8b c9 ff ff       	call   801001b5 <bread>
8010382a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
8010382d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103830:	83 c0 5c             	add    $0x5c,%eax
80103833:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103836:	8b 15 68 5c 11 80    	mov    0x80115c68,%edx
8010383c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010383f:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103841:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103848:	eb 1a                	jmp    80103864 <write_head+0x58>
    hb->block[i] = log.lh.block[i];
8010384a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010384d:	83 c0 10             	add    $0x10,%eax
80103850:	8b 0c 85 2c 5c 11 80 	mov    -0x7feea3d4(,%eax,4),%ecx
80103857:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010385a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010385d:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103861:	ff 45 f4             	incl   -0xc(%ebp)
80103864:	a1 68 5c 11 80       	mov    0x80115c68,%eax
80103869:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010386c:	7f dc                	jg     8010384a <write_head+0x3e>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
8010386e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103871:	89 04 24             	mov    %eax,(%esp)
80103874:	e8 73 c9 ff ff       	call   801001ec <bwrite>
  brelse(buf);
80103879:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010387c:	89 04 24             	mov    %eax,(%esp)
8010387f:	e8 a8 c9 ff ff       	call   8010022c <brelse>
}
80103884:	c9                   	leave  
80103885:	c3                   	ret    

80103886 <recover_from_log>:

static void
recover_from_log(void)
{
80103886:	55                   	push   %ebp
80103887:	89 e5                	mov    %esp,%ebp
80103889:	83 ec 08             	sub    $0x8,%esp
  read_head();
8010388c:	e8 0d ff ff ff       	call   8010379e <read_head>
  install_trans(); // if committed, copy from log to disk
80103891:	e8 5d fe ff ff       	call   801036f3 <install_trans>
  log.lh.n = 0;
80103896:	c7 05 68 5c 11 80 00 	movl   $0x0,0x80115c68
8010389d:	00 00 00 
  write_head(); // clear the log
801038a0:	e8 67 ff ff ff       	call   8010380c <write_head>
}
801038a5:	c9                   	leave  
801038a6:	c3                   	ret    

801038a7 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801038a7:	55                   	push   %ebp
801038a8:	89 e5                	mov    %esp,%ebp
801038aa:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
801038ad:	c7 04 24 20 5c 11 80 	movl   $0x80115c20,(%esp)
801038b4:	e8 0e 1f 00 00       	call   801057c7 <acquire>
  while(1){
    if(log.committing){
801038b9:	a1 60 5c 11 80       	mov    0x80115c60,%eax
801038be:	85 c0                	test   %eax,%eax
801038c0:	74 16                	je     801038d8 <begin_op+0x31>
      sleep(&log, &log.lock);
801038c2:	c7 44 24 04 20 5c 11 	movl   $0x80115c20,0x4(%esp)
801038c9:	80 
801038ca:	c7 04 24 20 5c 11 80 	movl   $0x80115c20,(%esp)
801038d1:	e8 f1 15 00 00       	call   80104ec7 <sleep>
801038d6:	eb 4d                	jmp    80103925 <begin_op+0x7e>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801038d8:	8b 15 68 5c 11 80    	mov    0x80115c68,%edx
801038de:	a1 5c 5c 11 80       	mov    0x80115c5c,%eax
801038e3:	8d 48 01             	lea    0x1(%eax),%ecx
801038e6:	89 c8                	mov    %ecx,%eax
801038e8:	c1 e0 02             	shl    $0x2,%eax
801038eb:	01 c8                	add    %ecx,%eax
801038ed:	01 c0                	add    %eax,%eax
801038ef:	01 d0                	add    %edx,%eax
801038f1:	83 f8 1e             	cmp    $0x1e,%eax
801038f4:	7e 16                	jle    8010390c <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801038f6:	c7 44 24 04 20 5c 11 	movl   $0x80115c20,0x4(%esp)
801038fd:	80 
801038fe:	c7 04 24 20 5c 11 80 	movl   $0x80115c20,(%esp)
80103905:	e8 bd 15 00 00       	call   80104ec7 <sleep>
8010390a:	eb 19                	jmp    80103925 <begin_op+0x7e>
    } else {
      log.outstanding += 1;
8010390c:	a1 5c 5c 11 80       	mov    0x80115c5c,%eax
80103911:	40                   	inc    %eax
80103912:	a3 5c 5c 11 80       	mov    %eax,0x80115c5c
      release(&log.lock);
80103917:	c7 04 24 20 5c 11 80 	movl   $0x80115c20,(%esp)
8010391e:	e8 0e 1f 00 00       	call   80105831 <release>
      break;
80103923:	eb 02                	jmp    80103927 <begin_op+0x80>
    }
  }
80103925:	eb 92                	jmp    801038b9 <begin_op+0x12>
}
80103927:	c9                   	leave  
80103928:	c3                   	ret    

80103929 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103929:	55                   	push   %ebp
8010392a:	89 e5                	mov    %esp,%ebp
8010392c:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
8010392f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103936:	c7 04 24 20 5c 11 80 	movl   $0x80115c20,(%esp)
8010393d:	e8 85 1e 00 00       	call   801057c7 <acquire>
  log.outstanding -= 1;
80103942:	a1 5c 5c 11 80       	mov    0x80115c5c,%eax
80103947:	48                   	dec    %eax
80103948:	a3 5c 5c 11 80       	mov    %eax,0x80115c5c
  if(log.committing)
8010394d:	a1 60 5c 11 80       	mov    0x80115c60,%eax
80103952:	85 c0                	test   %eax,%eax
80103954:	74 0c                	je     80103962 <end_op+0x39>
    panic("log.committing");
80103956:	c7 04 24 b9 9f 10 80 	movl   $0x80109fb9,(%esp)
8010395d:	e8 f2 cb ff ff       	call   80100554 <panic>
  if(log.outstanding == 0){
80103962:	a1 5c 5c 11 80       	mov    0x80115c5c,%eax
80103967:	85 c0                	test   %eax,%eax
80103969:	75 13                	jne    8010397e <end_op+0x55>
    do_commit = 1;
8010396b:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103972:	c7 05 60 5c 11 80 01 	movl   $0x1,0x80115c60
80103979:	00 00 00 
8010397c:	eb 0c                	jmp    8010398a <end_op+0x61>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
8010397e:	c7 04 24 20 5c 11 80 	movl   $0x80115c20,(%esp)
80103985:	e8 14 16 00 00       	call   80104f9e <wakeup>
  }
  release(&log.lock);
8010398a:	c7 04 24 20 5c 11 80 	movl   $0x80115c20,(%esp)
80103991:	e8 9b 1e 00 00       	call   80105831 <release>

  if(do_commit){
80103996:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010399a:	74 33                	je     801039cf <end_op+0xa6>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010399c:	e8 db 00 00 00       	call   80103a7c <commit>
    acquire(&log.lock);
801039a1:	c7 04 24 20 5c 11 80 	movl   $0x80115c20,(%esp)
801039a8:	e8 1a 1e 00 00       	call   801057c7 <acquire>
    log.committing = 0;
801039ad:	c7 05 60 5c 11 80 00 	movl   $0x0,0x80115c60
801039b4:	00 00 00 
    wakeup(&log);
801039b7:	c7 04 24 20 5c 11 80 	movl   $0x80115c20,(%esp)
801039be:	e8 db 15 00 00       	call   80104f9e <wakeup>
    release(&log.lock);
801039c3:	c7 04 24 20 5c 11 80 	movl   $0x80115c20,(%esp)
801039ca:	e8 62 1e 00 00       	call   80105831 <release>
  }
}
801039cf:	c9                   	leave  
801039d0:	c3                   	ret    

801039d1 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801039d1:	55                   	push   %ebp
801039d2:	89 e5                	mov    %esp,%ebp
801039d4:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801039d7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801039de:	e9 89 00 00 00       	jmp    80103a6c <write_log+0x9b>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801039e3:	8b 15 54 5c 11 80    	mov    0x80115c54,%edx
801039e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039ec:	01 d0                	add    %edx,%eax
801039ee:	40                   	inc    %eax
801039ef:	89 c2                	mov    %eax,%edx
801039f1:	a1 64 5c 11 80       	mov    0x80115c64,%eax
801039f6:	89 54 24 04          	mov    %edx,0x4(%esp)
801039fa:	89 04 24             	mov    %eax,(%esp)
801039fd:	e8 b3 c7 ff ff       	call   801001b5 <bread>
80103a02:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a08:	83 c0 10             	add    $0x10,%eax
80103a0b:	8b 04 85 2c 5c 11 80 	mov    -0x7feea3d4(,%eax,4),%eax
80103a12:	89 c2                	mov    %eax,%edx
80103a14:	a1 64 5c 11 80       	mov    0x80115c64,%eax
80103a19:	89 54 24 04          	mov    %edx,0x4(%esp)
80103a1d:	89 04 24             	mov    %eax,(%esp)
80103a20:	e8 90 c7 ff ff       	call   801001b5 <bread>
80103a25:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103a28:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a2b:	8d 50 5c             	lea    0x5c(%eax),%edx
80103a2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a31:	83 c0 5c             	add    $0x5c,%eax
80103a34:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103a3b:	00 
80103a3c:	89 54 24 04          	mov    %edx,0x4(%esp)
80103a40:	89 04 24             	mov    %eax,(%esp)
80103a43:	e8 ab 20 00 00       	call   80105af3 <memmove>
    bwrite(to);  // write the log
80103a48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a4b:	89 04 24             	mov    %eax,(%esp)
80103a4e:	e8 99 c7 ff ff       	call   801001ec <bwrite>
    brelse(from);
80103a53:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a56:	89 04 24             	mov    %eax,(%esp)
80103a59:	e8 ce c7 ff ff       	call   8010022c <brelse>
    brelse(to);
80103a5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a61:	89 04 24             	mov    %eax,(%esp)
80103a64:	e8 c3 c7 ff ff       	call   8010022c <brelse>
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103a69:	ff 45 f4             	incl   -0xc(%ebp)
80103a6c:	a1 68 5c 11 80       	mov    0x80115c68,%eax
80103a71:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a74:	0f 8f 69 ff ff ff    	jg     801039e3 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from);
    brelse(to);
  }
}
80103a7a:	c9                   	leave  
80103a7b:	c3                   	ret    

80103a7c <commit>:

static void
commit()
{
80103a7c:	55                   	push   %ebp
80103a7d:	89 e5                	mov    %esp,%ebp
80103a7f:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103a82:	a1 68 5c 11 80       	mov    0x80115c68,%eax
80103a87:	85 c0                	test   %eax,%eax
80103a89:	7e 1e                	jle    80103aa9 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103a8b:	e8 41 ff ff ff       	call   801039d1 <write_log>
    write_head();    // Write header to disk -- the real commit
80103a90:	e8 77 fd ff ff       	call   8010380c <write_head>
    install_trans(); // Now install writes to home locations
80103a95:	e8 59 fc ff ff       	call   801036f3 <install_trans>
    log.lh.n = 0;
80103a9a:	c7 05 68 5c 11 80 00 	movl   $0x0,0x80115c68
80103aa1:	00 00 00 
    write_head();    // Erase the transaction from the log
80103aa4:	e8 63 fd ff ff       	call   8010380c <write_head>
  }
}
80103aa9:	c9                   	leave  
80103aaa:	c3                   	ret    

80103aab <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103aab:	55                   	push   %ebp
80103aac:	89 e5                	mov    %esp,%ebp
80103aae:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103ab1:	a1 68 5c 11 80       	mov    0x80115c68,%eax
80103ab6:	83 f8 1d             	cmp    $0x1d,%eax
80103ab9:	7f 10                	jg     80103acb <log_write+0x20>
80103abb:	a1 68 5c 11 80       	mov    0x80115c68,%eax
80103ac0:	8b 15 58 5c 11 80    	mov    0x80115c58,%edx
80103ac6:	4a                   	dec    %edx
80103ac7:	39 d0                	cmp    %edx,%eax
80103ac9:	7c 0c                	jl     80103ad7 <log_write+0x2c>
    panic("too big a transaction");
80103acb:	c7 04 24 c8 9f 10 80 	movl   $0x80109fc8,(%esp)
80103ad2:	e8 7d ca ff ff       	call   80100554 <panic>
  if (log.outstanding < 1)
80103ad7:	a1 5c 5c 11 80       	mov    0x80115c5c,%eax
80103adc:	85 c0                	test   %eax,%eax
80103ade:	7f 0c                	jg     80103aec <log_write+0x41>
    panic("log_write outside of trans");
80103ae0:	c7 04 24 de 9f 10 80 	movl   $0x80109fde,(%esp)
80103ae7:	e8 68 ca ff ff       	call   80100554 <panic>

  acquire(&log.lock);
80103aec:	c7 04 24 20 5c 11 80 	movl   $0x80115c20,(%esp)
80103af3:	e8 cf 1c 00 00       	call   801057c7 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80103af8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103aff:	eb 1e                	jmp    80103b1f <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b04:	83 c0 10             	add    $0x10,%eax
80103b07:	8b 04 85 2c 5c 11 80 	mov    -0x7feea3d4(,%eax,4),%eax
80103b0e:	89 c2                	mov    %eax,%edx
80103b10:	8b 45 08             	mov    0x8(%ebp),%eax
80103b13:	8b 40 08             	mov    0x8(%eax),%eax
80103b16:	39 c2                	cmp    %eax,%edx
80103b18:	75 02                	jne    80103b1c <log_write+0x71>
      break;
80103b1a:	eb 0d                	jmp    80103b29 <log_write+0x7e>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103b1c:	ff 45 f4             	incl   -0xc(%ebp)
80103b1f:	a1 68 5c 11 80       	mov    0x80115c68,%eax
80103b24:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103b27:	7f d8                	jg     80103b01 <log_write+0x56>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
80103b29:	8b 45 08             	mov    0x8(%ebp),%eax
80103b2c:	8b 40 08             	mov    0x8(%eax),%eax
80103b2f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b32:	83 c2 10             	add    $0x10,%edx
80103b35:	89 04 95 2c 5c 11 80 	mov    %eax,-0x7feea3d4(,%edx,4)
  if (i == log.lh.n)
80103b3c:	a1 68 5c 11 80       	mov    0x80115c68,%eax
80103b41:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103b44:	75 0b                	jne    80103b51 <log_write+0xa6>
    log.lh.n++;
80103b46:	a1 68 5c 11 80       	mov    0x80115c68,%eax
80103b4b:	40                   	inc    %eax
80103b4c:	a3 68 5c 11 80       	mov    %eax,0x80115c68
  b->flags |= B_DIRTY; // prevent eviction
80103b51:	8b 45 08             	mov    0x8(%ebp),%eax
80103b54:	8b 00                	mov    (%eax),%eax
80103b56:	83 c8 04             	or     $0x4,%eax
80103b59:	89 c2                	mov    %eax,%edx
80103b5b:	8b 45 08             	mov    0x8(%ebp),%eax
80103b5e:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103b60:	c7 04 24 20 5c 11 80 	movl   $0x80115c20,(%esp)
80103b67:	e8 c5 1c 00 00       	call   80105831 <release>
}
80103b6c:	c9                   	leave  
80103b6d:	c3                   	ret    
	...

80103b70 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103b70:	55                   	push   %ebp
80103b71:	89 e5                	mov    %esp,%ebp
80103b73:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103b76:	8b 55 08             	mov    0x8(%ebp),%edx
80103b79:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103b7f:	f0 87 02             	lock xchg %eax,(%edx)
80103b82:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103b85:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103b88:	c9                   	leave  
80103b89:	c3                   	ret    

80103b8a <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103b8a:	55                   	push   %ebp
80103b8b:	89 e5                	mov    %esp,%ebp
80103b8d:	83 e4 f0             	and    $0xfffffff0,%esp
80103b90:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103b93:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103b9a:	80 
80103b9b:	c7 04 24 70 8e 11 80 	movl   $0x80118e70,(%esp)
80103ba2:	e8 dd f1 ff ff       	call   80102d84 <kinit1>
  kvmalloc();      // kernel page table
80103ba7:	e8 33 50 00 00       	call   80108bdf <kvmalloc>
  mpinit();        // detect other processors
80103bac:	e8 cc 03 00 00       	call   80103f7d <mpinit>
  lapicinit();     // interrupt controller
80103bb1:	e8 4e f6 ff ff       	call   80103204 <lapicinit>
  seginit();       // segment descriptors
80103bb6:	e8 0c 4b 00 00       	call   801086c7 <seginit>
  picinit();       // disable pic
80103bbb:	e8 0c 05 00 00       	call   801040cc <picinit>
  ioapicinit();    // another interrupt controller
80103bc0:	e8 dc f0 ff ff       	call   80102ca1 <ioapicinit>
  consoleinit();   // console hardware
80103bc5:	e8 25 d0 ff ff       	call   80100bef <consoleinit>
  uartinit();      // serial port
80103bca:	e8 84 3e 00 00       	call   80107a53 <uartinit>
  pinit();         // process table
80103bcf:	e8 ee 08 00 00       	call   801044c2 <pinit>
  tvinit();        // trap vectors
80103bd4:	e8 37 3a 00 00       	call   80107610 <tvinit>
  binit();         // buffer cache
80103bd9:	e8 56 c4 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103bde:	e8 03 d5 ff ff       	call   801010e6 <fileinit>
  ideinit();       // disk 
80103be3:	e8 c5 ec ff ff       	call   801028ad <ideinit>
  startothers();   // start other processors
80103be8:	e8 88 00 00 00       	call   80103c75 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103bed:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103bf4:	8e 
80103bf5:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80103bfc:	e8 bb f1 ff ff       	call   80102dbc <kinit2>
  container_init();
80103c01:	e8 cb 5e 00 00       	call   80109ad1 <container_init>
  userinit();      // first user process
80103c06:	e8 d7 0a 00 00       	call   801046e2 <userinit>
  mpmain();        // finish this processor's setup
80103c0b:	e8 1a 00 00 00       	call   80103c2a <mpmain>

80103c10 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103c10:	55                   	push   %ebp
80103c11:	89 e5                	mov    %esp,%ebp
80103c13:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103c16:	e8 db 4f 00 00       	call   80108bf6 <switchkvm>
  seginit();
80103c1b:	e8 a7 4a 00 00       	call   801086c7 <seginit>
  lapicinit();
80103c20:	e8 df f5 ff ff       	call   80103204 <lapicinit>
  mpmain();
80103c25:	e8 00 00 00 00       	call   80103c2a <mpmain>

80103c2a <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103c2a:	55                   	push   %ebp
80103c2b:	89 e5                	mov    %esp,%ebp
80103c2d:	53                   	push   %ebx
80103c2e:	83 ec 14             	sub    $0x14,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103c31:	e8 a8 08 00 00       	call   801044de <cpuid>
80103c36:	89 c3                	mov    %eax,%ebx
80103c38:	e8 a1 08 00 00       	call   801044de <cpuid>
80103c3d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80103c41:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c45:	c7 04 24 f9 9f 10 80 	movl   $0x80109ff9,(%esp)
80103c4c:	e8 70 c7 ff ff       	call   801003c1 <cprintf>
  idtinit();       // load idt register
80103c51:	e8 17 3b 00 00       	call   8010776d <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103c56:	e8 c8 08 00 00       	call   80104523 <mycpu>
80103c5b:	05 a0 00 00 00       	add    $0xa0,%eax
80103c60:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103c67:	00 
80103c68:	89 04 24             	mov    %eax,(%esp)
80103c6b:	e8 00 ff ff ff       	call   80103b70 <xchg>
  scheduler();     // start running processes
80103c70:	e8 16 10 00 00       	call   80104c8b <scheduler>

80103c75 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103c75:	55                   	push   %ebp
80103c76:	89 e5                	mov    %esp,%ebp
80103c78:	83 ec 28             	sub    $0x28,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103c7b:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103c82:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103c87:	89 44 24 08          	mov    %eax,0x8(%esp)
80103c8b:	c7 44 24 04 d0 d5 10 	movl   $0x8010d5d0,0x4(%esp)
80103c92:	80 
80103c93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c96:	89 04 24             	mov    %eax,(%esp)
80103c99:	e8 55 1e 00 00       	call   80105af3 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103c9e:	c7 45 f4 20 5d 11 80 	movl   $0x80115d20,-0xc(%ebp)
80103ca5:	eb 75                	jmp    80103d1c <startothers+0xa7>
    if(c == mycpu())  // We've started already.
80103ca7:	e8 77 08 00 00       	call   80104523 <mycpu>
80103cac:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103caf:	75 02                	jne    80103cb3 <startothers+0x3e>
      continue;
80103cb1:	eb 62                	jmp    80103d15 <startothers+0xa0>

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103cb3:	e8 59 f2 ff ff       	call   80102f11 <kalloc>
80103cb8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103cbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cbe:	83 e8 04             	sub    $0x4,%eax
80103cc1:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103cc4:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103cca:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103ccc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ccf:	83 e8 08             	sub    $0x8,%eax
80103cd2:	c7 00 10 3c 10 80    	movl   $0x80103c10,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103cd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cdb:	8d 50 f4             	lea    -0xc(%eax),%edx
80103cde:	b8 00 c0 10 80       	mov    $0x8010c000,%eax
80103ce3:	05 00 00 00 80       	add    $0x80000000,%eax
80103ce8:	89 02                	mov    %eax,(%edx)

    lapicstartap(c->apicid, V2P(code));
80103cea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ced:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103cf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cf6:	8a 00                	mov    (%eax),%al
80103cf8:	0f b6 c0             	movzbl %al,%eax
80103cfb:	89 54 24 04          	mov    %edx,0x4(%esp)
80103cff:	89 04 24             	mov    %eax,(%esp)
80103d02:	e8 a2 f6 ff ff       	call   801033a9 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103d07:	90                   	nop
80103d08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d0b:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103d11:	85 c0                	test   %eax,%eax
80103d13:	74 f3                	je     80103d08 <startothers+0x93>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103d15:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103d1c:	a1 a0 62 11 80       	mov    0x801162a0,%eax
80103d21:	89 c2                	mov    %eax,%edx
80103d23:	89 d0                	mov    %edx,%eax
80103d25:	c1 e0 02             	shl    $0x2,%eax
80103d28:	01 d0                	add    %edx,%eax
80103d2a:	01 c0                	add    %eax,%eax
80103d2c:	01 d0                	add    %edx,%eax
80103d2e:	c1 e0 04             	shl    $0x4,%eax
80103d31:	05 20 5d 11 80       	add    $0x80115d20,%eax
80103d36:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103d39:	0f 87 68 ff ff ff    	ja     80103ca7 <startothers+0x32>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103d3f:	c9                   	leave  
80103d40:	c3                   	ret    
80103d41:	00 00                	add    %al,(%eax)
	...

80103d44 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103d44:	55                   	push   %ebp
80103d45:	89 e5                	mov    %esp,%ebp
80103d47:	83 ec 14             	sub    $0x14,%esp
80103d4a:	8b 45 08             	mov    0x8(%ebp),%eax
80103d4d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103d51:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d54:	89 c2                	mov    %eax,%edx
80103d56:	ec                   	in     (%dx),%al
80103d57:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103d5a:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80103d5d:	c9                   	leave  
80103d5e:	c3                   	ret    

80103d5f <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103d5f:	55                   	push   %ebp
80103d60:	89 e5                	mov    %esp,%ebp
80103d62:	83 ec 08             	sub    $0x8,%esp
80103d65:	8b 45 08             	mov    0x8(%ebp),%eax
80103d68:	8b 55 0c             	mov    0xc(%ebp),%edx
80103d6b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103d6f:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103d72:	8a 45 f8             	mov    -0x8(%ebp),%al
80103d75:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103d78:	ee                   	out    %al,(%dx)
}
80103d79:	c9                   	leave  
80103d7a:	c3                   	ret    

80103d7b <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103d7b:	55                   	push   %ebp
80103d7c:	89 e5                	mov    %esp,%ebp
80103d7e:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103d81:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103d88:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103d8f:	eb 13                	jmp    80103da4 <sum+0x29>
    sum += addr[i];
80103d91:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103d94:	8b 45 08             	mov    0x8(%ebp),%eax
80103d97:	01 d0                	add    %edx,%eax
80103d99:	8a 00                	mov    (%eax),%al
80103d9b:	0f b6 c0             	movzbl %al,%eax
80103d9e:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80103da1:	ff 45 fc             	incl   -0x4(%ebp)
80103da4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103da7:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103daa:	7c e5                	jl     80103d91 <sum+0x16>
    sum += addr[i];
  return sum;
80103dac:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103daf:	c9                   	leave  
80103db0:	c3                   	ret    

80103db1 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103db1:	55                   	push   %ebp
80103db2:	89 e5                	mov    %esp,%ebp
80103db4:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103db7:	8b 45 08             	mov    0x8(%ebp),%eax
80103dba:	05 00 00 00 80       	add    $0x80000000,%eax
80103dbf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103dc2:	8b 55 0c             	mov    0xc(%ebp),%edx
80103dc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dc8:	01 d0                	add    %edx,%eax
80103dca:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103dcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dd0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103dd3:	eb 3f                	jmp    80103e14 <mpsearch1+0x63>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103dd5:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103ddc:	00 
80103ddd:	c7 44 24 04 10 a0 10 	movl   $0x8010a010,0x4(%esp)
80103de4:	80 
80103de5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103de8:	89 04 24             	mov    %eax,(%esp)
80103deb:	e8 b1 1c 00 00       	call   80105aa1 <memcmp>
80103df0:	85 c0                	test   %eax,%eax
80103df2:	75 1c                	jne    80103e10 <mpsearch1+0x5f>
80103df4:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103dfb:	00 
80103dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dff:	89 04 24             	mov    %eax,(%esp)
80103e02:	e8 74 ff ff ff       	call   80103d7b <sum>
80103e07:	84 c0                	test   %al,%al
80103e09:	75 05                	jne    80103e10 <mpsearch1+0x5f>
      return (struct mp*)p;
80103e0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e0e:	eb 11                	jmp    80103e21 <mpsearch1+0x70>
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103e10:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e17:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103e1a:	72 b9                	jb     80103dd5 <mpsearch1+0x24>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103e1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103e21:	c9                   	leave  
80103e22:	c3                   	ret    

80103e23 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103e23:	55                   	push   %ebp
80103e24:	89 e5                	mov    %esp,%ebp
80103e26:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103e29:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103e30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e33:	83 c0 0f             	add    $0xf,%eax
80103e36:	8a 00                	mov    (%eax),%al
80103e38:	0f b6 c0             	movzbl %al,%eax
80103e3b:	c1 e0 08             	shl    $0x8,%eax
80103e3e:	89 c2                	mov    %eax,%edx
80103e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e43:	83 c0 0e             	add    $0xe,%eax
80103e46:	8a 00                	mov    (%eax),%al
80103e48:	0f b6 c0             	movzbl %al,%eax
80103e4b:	09 d0                	or     %edx,%eax
80103e4d:	c1 e0 04             	shl    $0x4,%eax
80103e50:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103e53:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103e57:	74 21                	je     80103e7a <mpsearch+0x57>
    if((mp = mpsearch1(p, 1024)))
80103e59:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103e60:	00 
80103e61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e64:	89 04 24             	mov    %eax,(%esp)
80103e67:	e8 45 ff ff ff       	call   80103db1 <mpsearch1>
80103e6c:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103e6f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103e73:	74 4e                	je     80103ec3 <mpsearch+0xa0>
      return mp;
80103e75:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e78:	eb 5d                	jmp    80103ed7 <mpsearch+0xb4>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103e7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e7d:	83 c0 14             	add    $0x14,%eax
80103e80:	8a 00                	mov    (%eax),%al
80103e82:	0f b6 c0             	movzbl %al,%eax
80103e85:	c1 e0 08             	shl    $0x8,%eax
80103e88:	89 c2                	mov    %eax,%edx
80103e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e8d:	83 c0 13             	add    $0x13,%eax
80103e90:	8a 00                	mov    (%eax),%al
80103e92:	0f b6 c0             	movzbl %al,%eax
80103e95:	09 d0                	or     %edx,%eax
80103e97:	c1 e0 0a             	shl    $0xa,%eax
80103e9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103e9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ea0:	2d 00 04 00 00       	sub    $0x400,%eax
80103ea5:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103eac:	00 
80103ead:	89 04 24             	mov    %eax,(%esp)
80103eb0:	e8 fc fe ff ff       	call   80103db1 <mpsearch1>
80103eb5:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103eb8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103ebc:	74 05                	je     80103ec3 <mpsearch+0xa0>
      return mp;
80103ebe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ec1:	eb 14                	jmp    80103ed7 <mpsearch+0xb4>
  }
  return mpsearch1(0xF0000, 0x10000);
80103ec3:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103eca:	00 
80103ecb:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103ed2:	e8 da fe ff ff       	call   80103db1 <mpsearch1>
}
80103ed7:	c9                   	leave  
80103ed8:	c3                   	ret    

80103ed9 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103ed9:	55                   	push   %ebp
80103eda:	89 e5                	mov    %esp,%ebp
80103edc:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103edf:	e8 3f ff ff ff       	call   80103e23 <mpsearch>
80103ee4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ee7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103eeb:	74 0a                	je     80103ef7 <mpconfig+0x1e>
80103eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ef0:	8b 40 04             	mov    0x4(%eax),%eax
80103ef3:	85 c0                	test   %eax,%eax
80103ef5:	75 07                	jne    80103efe <mpconfig+0x25>
    return 0;
80103ef7:	b8 00 00 00 00       	mov    $0x0,%eax
80103efc:	eb 7d                	jmp    80103f7b <mpconfig+0xa2>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103efe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f01:	8b 40 04             	mov    0x4(%eax),%eax
80103f04:	05 00 00 00 80       	add    $0x80000000,%eax
80103f09:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103f0c:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103f13:	00 
80103f14:	c7 44 24 04 15 a0 10 	movl   $0x8010a015,0x4(%esp)
80103f1b:	80 
80103f1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f1f:	89 04 24             	mov    %eax,(%esp)
80103f22:	e8 7a 1b 00 00       	call   80105aa1 <memcmp>
80103f27:	85 c0                	test   %eax,%eax
80103f29:	74 07                	je     80103f32 <mpconfig+0x59>
    return 0;
80103f2b:	b8 00 00 00 00       	mov    $0x0,%eax
80103f30:	eb 49                	jmp    80103f7b <mpconfig+0xa2>
  if(conf->version != 1 && conf->version != 4)
80103f32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f35:	8a 40 06             	mov    0x6(%eax),%al
80103f38:	3c 01                	cmp    $0x1,%al
80103f3a:	74 11                	je     80103f4d <mpconfig+0x74>
80103f3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f3f:	8a 40 06             	mov    0x6(%eax),%al
80103f42:	3c 04                	cmp    $0x4,%al
80103f44:	74 07                	je     80103f4d <mpconfig+0x74>
    return 0;
80103f46:	b8 00 00 00 00       	mov    $0x0,%eax
80103f4b:	eb 2e                	jmp    80103f7b <mpconfig+0xa2>
  if(sum((uchar*)conf, conf->length) != 0)
80103f4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f50:	8b 40 04             	mov    0x4(%eax),%eax
80103f53:	0f b7 c0             	movzwl %ax,%eax
80103f56:	89 44 24 04          	mov    %eax,0x4(%esp)
80103f5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f5d:	89 04 24             	mov    %eax,(%esp)
80103f60:	e8 16 fe ff ff       	call   80103d7b <sum>
80103f65:	84 c0                	test   %al,%al
80103f67:	74 07                	je     80103f70 <mpconfig+0x97>
    return 0;
80103f69:	b8 00 00 00 00       	mov    $0x0,%eax
80103f6e:	eb 0b                	jmp    80103f7b <mpconfig+0xa2>
  *pmp = mp;
80103f70:	8b 45 08             	mov    0x8(%ebp),%eax
80103f73:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f76:	89 10                	mov    %edx,(%eax)
  return conf;
80103f78:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103f7b:	c9                   	leave  
80103f7c:	c3                   	ret    

80103f7d <mpinit>:

void
mpinit(void)
{
80103f7d:	55                   	push   %ebp
80103f7e:	89 e5                	mov    %esp,%ebp
80103f80:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103f83:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103f86:	89 04 24             	mov    %eax,(%esp)
80103f89:	e8 4b ff ff ff       	call   80103ed9 <mpconfig>
80103f8e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103f91:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103f95:	75 0c                	jne    80103fa3 <mpinit+0x26>
    panic("Expect to run on an SMP");
80103f97:	c7 04 24 1a a0 10 80 	movl   $0x8010a01a,(%esp)
80103f9e:	e8 b1 c5 ff ff       	call   80100554 <panic>
  ismp = 1;
80103fa3:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103faa:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fad:	8b 40 24             	mov    0x24(%eax),%eax
80103fb0:	a3 00 5c 11 80       	mov    %eax,0x80115c00
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103fb5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fb8:	83 c0 2c             	add    $0x2c,%eax
80103fbb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103fbe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fc1:	8b 40 04             	mov    0x4(%eax),%eax
80103fc4:	0f b7 d0             	movzwl %ax,%edx
80103fc7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fca:	01 d0                	add    %edx,%eax
80103fcc:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103fcf:	eb 7d                	jmp    8010404e <mpinit+0xd1>
    switch(*p){
80103fd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fd4:	8a 00                	mov    (%eax),%al
80103fd6:	0f b6 c0             	movzbl %al,%eax
80103fd9:	83 f8 04             	cmp    $0x4,%eax
80103fdc:	77 68                	ja     80104046 <mpinit+0xc9>
80103fde:	8b 04 85 54 a0 10 80 	mov    -0x7fef5fac(,%eax,4),%eax
80103fe5:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103fe7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu < NCPU) {
80103fed:	a1 a0 62 11 80       	mov    0x801162a0,%eax
80103ff2:	83 f8 07             	cmp    $0x7,%eax
80103ff5:	7f 2c                	jg     80104023 <mpinit+0xa6>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103ff7:	8b 15 a0 62 11 80    	mov    0x801162a0,%edx
80103ffd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104000:	8a 48 01             	mov    0x1(%eax),%cl
80104003:	89 d0                	mov    %edx,%eax
80104005:	c1 e0 02             	shl    $0x2,%eax
80104008:	01 d0                	add    %edx,%eax
8010400a:	01 c0                	add    %eax,%eax
8010400c:	01 d0                	add    %edx,%eax
8010400e:	c1 e0 04             	shl    $0x4,%eax
80104011:	05 20 5d 11 80       	add    $0x80115d20,%eax
80104016:	88 08                	mov    %cl,(%eax)
        ncpu++;
80104018:	a1 a0 62 11 80       	mov    0x801162a0,%eax
8010401d:	40                   	inc    %eax
8010401e:	a3 a0 62 11 80       	mov    %eax,0x801162a0
      }
      p += sizeof(struct mpproc);
80104023:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80104027:	eb 25                	jmp    8010404e <mpinit+0xd1>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80104029:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010402c:	89 45 e0             	mov    %eax,-0x20(%ebp)
      ioapicid = ioapic->apicno;
8010402f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104032:	8a 40 01             	mov    0x1(%eax),%al
80104035:	a2 00 5d 11 80       	mov    %al,0x80115d00
      p += sizeof(struct mpioapic);
8010403a:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
8010403e:	eb 0e                	jmp    8010404e <mpinit+0xd1>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80104040:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80104044:	eb 08                	jmp    8010404e <mpinit+0xd1>
    default:
      ismp = 0;
80104046:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
8010404d:	90                   	nop

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010404e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104051:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80104054:	0f 82 77 ff ff ff    	jb     80103fd1 <mpinit+0x54>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
8010405a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010405e:	75 0c                	jne    8010406c <mpinit+0xef>
    panic("Didn't find a suitable machine");
80104060:	c7 04 24 34 a0 10 80 	movl   $0x8010a034,(%esp)
80104067:	e8 e8 c4 ff ff       	call   80100554 <panic>

  if(mp->imcrp){
8010406c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010406f:	8a 40 0c             	mov    0xc(%eax),%al
80104072:	84 c0                	test   %al,%al
80104074:	74 36                	je     801040ac <mpinit+0x12f>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80104076:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
8010407d:	00 
8010407e:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80104085:	e8 d5 fc ff ff       	call   80103d5f <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
8010408a:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80104091:	e8 ae fc ff ff       	call   80103d44 <inb>
80104096:	83 c8 01             	or     $0x1,%eax
80104099:	0f b6 c0             	movzbl %al,%eax
8010409c:	89 44 24 04          	mov    %eax,0x4(%esp)
801040a0:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
801040a7:	e8 b3 fc ff ff       	call   80103d5f <outb>
  }
}
801040ac:	c9                   	leave  
801040ad:	c3                   	ret    
	...

801040b0 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801040b0:	55                   	push   %ebp
801040b1:	89 e5                	mov    %esp,%ebp
801040b3:	83 ec 08             	sub    $0x8,%esp
801040b6:	8b 45 08             	mov    0x8(%ebp),%eax
801040b9:	8b 55 0c             	mov    0xc(%ebp),%edx
801040bc:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801040c0:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801040c3:	8a 45 f8             	mov    -0x8(%ebp),%al
801040c6:	8b 55 fc             	mov    -0x4(%ebp),%edx
801040c9:	ee                   	out    %al,(%dx)
}
801040ca:	c9                   	leave  
801040cb:	c3                   	ret    

801040cc <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
801040cc:	55                   	push   %ebp
801040cd:	89 e5                	mov    %esp,%ebp
801040cf:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
801040d2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
801040d9:	00 
801040da:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
801040e1:	e8 ca ff ff ff       	call   801040b0 <outb>
  outb(IO_PIC2+1, 0xFF);
801040e6:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
801040ed:	00 
801040ee:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
801040f5:	e8 b6 ff ff ff       	call   801040b0 <outb>
}
801040fa:	c9                   	leave  
801040fb:	c3                   	ret    

801040fc <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
801040fc:	55                   	push   %ebp
801040fd:	89 e5                	mov    %esp,%ebp
801040ff:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80104102:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104109:	8b 45 0c             	mov    0xc(%ebp),%eax
8010410c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104112:	8b 45 0c             	mov    0xc(%ebp),%eax
80104115:	8b 10                	mov    (%eax),%edx
80104117:	8b 45 08             	mov    0x8(%ebp),%eax
8010411a:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010411c:	e8 e1 cf ff ff       	call   80101102 <filealloc>
80104121:	8b 55 08             	mov    0x8(%ebp),%edx
80104124:	89 02                	mov    %eax,(%edx)
80104126:	8b 45 08             	mov    0x8(%ebp),%eax
80104129:	8b 00                	mov    (%eax),%eax
8010412b:	85 c0                	test   %eax,%eax
8010412d:	0f 84 c8 00 00 00    	je     801041fb <pipealloc+0xff>
80104133:	e8 ca cf ff ff       	call   80101102 <filealloc>
80104138:	8b 55 0c             	mov    0xc(%ebp),%edx
8010413b:	89 02                	mov    %eax,(%edx)
8010413d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104140:	8b 00                	mov    (%eax),%eax
80104142:	85 c0                	test   %eax,%eax
80104144:	0f 84 b1 00 00 00    	je     801041fb <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
8010414a:	e8 c2 ed ff ff       	call   80102f11 <kalloc>
8010414f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104152:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104156:	75 05                	jne    8010415d <pipealloc+0x61>
    goto bad;
80104158:	e9 9e 00 00 00       	jmp    801041fb <pipealloc+0xff>
  p->readopen = 1;
8010415d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104160:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104167:	00 00 00 
  p->writeopen = 1;
8010416a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010416d:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104174:	00 00 00 
  p->nwrite = 0;
80104177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010417a:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104181:	00 00 00 
  p->nread = 0;
80104184:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104187:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
8010418e:	00 00 00 
  initlock(&p->lock, "pipe");
80104191:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104194:	c7 44 24 04 68 a0 10 	movl   $0x8010a068,0x4(%esp)
8010419b:	80 
8010419c:	89 04 24             	mov    %eax,(%esp)
8010419f:	e8 02 16 00 00       	call   801057a6 <initlock>
  (*f0)->type = FD_PIPE;
801041a4:	8b 45 08             	mov    0x8(%ebp),%eax
801041a7:	8b 00                	mov    (%eax),%eax
801041a9:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801041af:	8b 45 08             	mov    0x8(%ebp),%eax
801041b2:	8b 00                	mov    (%eax),%eax
801041b4:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801041b8:	8b 45 08             	mov    0x8(%ebp),%eax
801041bb:	8b 00                	mov    (%eax),%eax
801041bd:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801041c1:	8b 45 08             	mov    0x8(%ebp),%eax
801041c4:	8b 00                	mov    (%eax),%eax
801041c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041c9:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
801041cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801041cf:	8b 00                	mov    (%eax),%eax
801041d1:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801041d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801041da:	8b 00                	mov    (%eax),%eax
801041dc:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801041e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801041e3:	8b 00                	mov    (%eax),%eax
801041e5:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801041e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801041ec:	8b 00                	mov    (%eax),%eax
801041ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041f1:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801041f4:	b8 00 00 00 00       	mov    $0x0,%eax
801041f9:	eb 42                	jmp    8010423d <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
801041fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801041ff:	74 0b                	je     8010420c <pipealloc+0x110>
    kfree((char*)p);
80104201:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104204:	89 04 24             	mov    %eax,(%esp)
80104207:	e8 17 ec ff ff       	call   80102e23 <kfree>
  if(*f0)
8010420c:	8b 45 08             	mov    0x8(%ebp),%eax
8010420f:	8b 00                	mov    (%eax),%eax
80104211:	85 c0                	test   %eax,%eax
80104213:	74 0d                	je     80104222 <pipealloc+0x126>
    fileclose(*f0);
80104215:	8b 45 08             	mov    0x8(%ebp),%eax
80104218:	8b 00                	mov    (%eax),%eax
8010421a:	89 04 24             	mov    %eax,(%esp)
8010421d:	e8 88 cf ff ff       	call   801011aa <fileclose>
  if(*f1)
80104222:	8b 45 0c             	mov    0xc(%ebp),%eax
80104225:	8b 00                	mov    (%eax),%eax
80104227:	85 c0                	test   %eax,%eax
80104229:	74 0d                	je     80104238 <pipealloc+0x13c>
    fileclose(*f1);
8010422b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010422e:	8b 00                	mov    (%eax),%eax
80104230:	89 04 24             	mov    %eax,(%esp)
80104233:	e8 72 cf ff ff       	call   801011aa <fileclose>
  return -1;
80104238:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010423d:	c9                   	leave  
8010423e:	c3                   	ret    

8010423f <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
8010423f:	55                   	push   %ebp
80104240:	89 e5                	mov    %esp,%ebp
80104242:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80104245:	8b 45 08             	mov    0x8(%ebp),%eax
80104248:	89 04 24             	mov    %eax,(%esp)
8010424b:	e8 77 15 00 00       	call   801057c7 <acquire>
  if(writable){
80104250:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104254:	74 1f                	je     80104275 <pipeclose+0x36>
    p->writeopen = 0;
80104256:	8b 45 08             	mov    0x8(%ebp),%eax
80104259:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104260:	00 00 00 
    wakeup(&p->nread);
80104263:	8b 45 08             	mov    0x8(%ebp),%eax
80104266:	05 34 02 00 00       	add    $0x234,%eax
8010426b:	89 04 24             	mov    %eax,(%esp)
8010426e:	e8 2b 0d 00 00       	call   80104f9e <wakeup>
80104273:	eb 1d                	jmp    80104292 <pipeclose+0x53>
  } else {
    p->readopen = 0;
80104275:	8b 45 08             	mov    0x8(%ebp),%eax
80104278:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010427f:	00 00 00 
    wakeup(&p->nwrite);
80104282:	8b 45 08             	mov    0x8(%ebp),%eax
80104285:	05 38 02 00 00       	add    $0x238,%eax
8010428a:	89 04 24             	mov    %eax,(%esp)
8010428d:	e8 0c 0d 00 00       	call   80104f9e <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104292:	8b 45 08             	mov    0x8(%ebp),%eax
80104295:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010429b:	85 c0                	test   %eax,%eax
8010429d:	75 25                	jne    801042c4 <pipeclose+0x85>
8010429f:	8b 45 08             	mov    0x8(%ebp),%eax
801042a2:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801042a8:	85 c0                	test   %eax,%eax
801042aa:	75 18                	jne    801042c4 <pipeclose+0x85>
    release(&p->lock);
801042ac:	8b 45 08             	mov    0x8(%ebp),%eax
801042af:	89 04 24             	mov    %eax,(%esp)
801042b2:	e8 7a 15 00 00       	call   80105831 <release>
    kfree((char*)p);
801042b7:	8b 45 08             	mov    0x8(%ebp),%eax
801042ba:	89 04 24             	mov    %eax,(%esp)
801042bd:	e8 61 eb ff ff       	call   80102e23 <kfree>
801042c2:	eb 0b                	jmp    801042cf <pipeclose+0x90>
  } else
    release(&p->lock);
801042c4:	8b 45 08             	mov    0x8(%ebp),%eax
801042c7:	89 04 24             	mov    %eax,(%esp)
801042ca:	e8 62 15 00 00       	call   80105831 <release>
}
801042cf:	c9                   	leave  
801042d0:	c3                   	ret    

801042d1 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801042d1:	55                   	push   %ebp
801042d2:	89 e5                	mov    %esp,%ebp
801042d4:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
801042d7:	8b 45 08             	mov    0x8(%ebp),%eax
801042da:	89 04 24             	mov    %eax,(%esp)
801042dd:	e8 e5 14 00 00       	call   801057c7 <acquire>
  for(i = 0; i < n; i++){
801042e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801042e9:	e9 a3 00 00 00       	jmp    80104391 <pipewrite+0xc0>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801042ee:	eb 56                	jmp    80104346 <pipewrite+0x75>
      if(p->readopen == 0 || myproc()->killed){
801042f0:	8b 45 08             	mov    0x8(%ebp),%eax
801042f3:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801042f9:	85 c0                	test   %eax,%eax
801042fb:	74 0c                	je     80104309 <pipewrite+0x38>
801042fd:	e8 a5 02 00 00       	call   801045a7 <myproc>
80104302:	8b 40 24             	mov    0x24(%eax),%eax
80104305:	85 c0                	test   %eax,%eax
80104307:	74 15                	je     8010431e <pipewrite+0x4d>
        release(&p->lock);
80104309:	8b 45 08             	mov    0x8(%ebp),%eax
8010430c:	89 04 24             	mov    %eax,(%esp)
8010430f:	e8 1d 15 00 00       	call   80105831 <release>
        return -1;
80104314:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104319:	e9 9d 00 00 00       	jmp    801043bb <pipewrite+0xea>
      }
      wakeup(&p->nread);
8010431e:	8b 45 08             	mov    0x8(%ebp),%eax
80104321:	05 34 02 00 00       	add    $0x234,%eax
80104326:	89 04 24             	mov    %eax,(%esp)
80104329:	e8 70 0c 00 00       	call   80104f9e <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010432e:	8b 45 08             	mov    0x8(%ebp),%eax
80104331:	8b 55 08             	mov    0x8(%ebp),%edx
80104334:	81 c2 38 02 00 00    	add    $0x238,%edx
8010433a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010433e:	89 14 24             	mov    %edx,(%esp)
80104341:	e8 81 0b 00 00       	call   80104ec7 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104346:	8b 45 08             	mov    0x8(%ebp),%eax
80104349:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
8010434f:	8b 45 08             	mov    0x8(%ebp),%eax
80104352:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104358:	05 00 02 00 00       	add    $0x200,%eax
8010435d:	39 c2                	cmp    %eax,%edx
8010435f:	74 8f                	je     801042f0 <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104361:	8b 45 08             	mov    0x8(%ebp),%eax
80104364:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010436a:	8d 48 01             	lea    0x1(%eax),%ecx
8010436d:	8b 55 08             	mov    0x8(%ebp),%edx
80104370:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104376:	25 ff 01 00 00       	and    $0x1ff,%eax
8010437b:	89 c1                	mov    %eax,%ecx
8010437d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104380:	8b 45 0c             	mov    0xc(%ebp),%eax
80104383:	01 d0                	add    %edx,%eax
80104385:	8a 10                	mov    (%eax),%dl
80104387:	8b 45 08             	mov    0x8(%ebp),%eax
8010438a:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
8010438e:	ff 45 f4             	incl   -0xc(%ebp)
80104391:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104394:	3b 45 10             	cmp    0x10(%ebp),%eax
80104397:	0f 8c 51 ff ff ff    	jl     801042ee <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
8010439d:	8b 45 08             	mov    0x8(%ebp),%eax
801043a0:	05 34 02 00 00       	add    $0x234,%eax
801043a5:	89 04 24             	mov    %eax,(%esp)
801043a8:	e8 f1 0b 00 00       	call   80104f9e <wakeup>
  release(&p->lock);
801043ad:	8b 45 08             	mov    0x8(%ebp),%eax
801043b0:	89 04 24             	mov    %eax,(%esp)
801043b3:	e8 79 14 00 00       	call   80105831 <release>
  return n;
801043b8:	8b 45 10             	mov    0x10(%ebp),%eax
}
801043bb:	c9                   	leave  
801043bc:	c3                   	ret    

801043bd <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801043bd:	55                   	push   %ebp
801043be:	89 e5                	mov    %esp,%ebp
801043c0:	53                   	push   %ebx
801043c1:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
801043c4:	8b 45 08             	mov    0x8(%ebp),%eax
801043c7:	89 04 24             	mov    %eax,(%esp)
801043ca:	e8 f8 13 00 00       	call   801057c7 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801043cf:	eb 39                	jmp    8010440a <piperead+0x4d>
    if(myproc()->killed){
801043d1:	e8 d1 01 00 00       	call   801045a7 <myproc>
801043d6:	8b 40 24             	mov    0x24(%eax),%eax
801043d9:	85 c0                	test   %eax,%eax
801043db:	74 15                	je     801043f2 <piperead+0x35>
      release(&p->lock);
801043dd:	8b 45 08             	mov    0x8(%ebp),%eax
801043e0:	89 04 24             	mov    %eax,(%esp)
801043e3:	e8 49 14 00 00       	call   80105831 <release>
      return -1;
801043e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043ed:	e9 b3 00 00 00       	jmp    801044a5 <piperead+0xe8>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801043f2:	8b 45 08             	mov    0x8(%ebp),%eax
801043f5:	8b 55 08             	mov    0x8(%ebp),%edx
801043f8:	81 c2 34 02 00 00    	add    $0x234,%edx
801043fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80104402:	89 14 24             	mov    %edx,(%esp)
80104405:	e8 bd 0a 00 00       	call   80104ec7 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010440a:	8b 45 08             	mov    0x8(%ebp),%eax
8010440d:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104413:	8b 45 08             	mov    0x8(%ebp),%eax
80104416:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010441c:	39 c2                	cmp    %eax,%edx
8010441e:	75 0d                	jne    8010442d <piperead+0x70>
80104420:	8b 45 08             	mov    0x8(%ebp),%eax
80104423:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104429:	85 c0                	test   %eax,%eax
8010442b:	75 a4                	jne    801043d1 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010442d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104434:	eb 49                	jmp    8010447f <piperead+0xc2>
    if(p->nread == p->nwrite)
80104436:	8b 45 08             	mov    0x8(%ebp),%eax
80104439:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010443f:	8b 45 08             	mov    0x8(%ebp),%eax
80104442:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104448:	39 c2                	cmp    %eax,%edx
8010444a:	75 02                	jne    8010444e <piperead+0x91>
      break;
8010444c:	eb 39                	jmp    80104487 <piperead+0xca>
    addr[i] = p->data[p->nread++ % PIPESIZE];
8010444e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104451:	8b 45 0c             	mov    0xc(%ebp),%eax
80104454:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104457:	8b 45 08             	mov    0x8(%ebp),%eax
8010445a:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104460:	8d 48 01             	lea    0x1(%eax),%ecx
80104463:	8b 55 08             	mov    0x8(%ebp),%edx
80104466:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
8010446c:	25 ff 01 00 00       	and    $0x1ff,%eax
80104471:	89 c2                	mov    %eax,%edx
80104473:	8b 45 08             	mov    0x8(%ebp),%eax
80104476:	8a 44 10 34          	mov    0x34(%eax,%edx,1),%al
8010447a:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010447c:	ff 45 f4             	incl   -0xc(%ebp)
8010447f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104482:	3b 45 10             	cmp    0x10(%ebp),%eax
80104485:	7c af                	jl     80104436 <piperead+0x79>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104487:	8b 45 08             	mov    0x8(%ebp),%eax
8010448a:	05 38 02 00 00       	add    $0x238,%eax
8010448f:	89 04 24             	mov    %eax,(%esp)
80104492:	e8 07 0b 00 00       	call   80104f9e <wakeup>
  release(&p->lock);
80104497:	8b 45 08             	mov    0x8(%ebp),%eax
8010449a:	89 04 24             	mov    %eax,(%esp)
8010449d:	e8 8f 13 00 00       	call   80105831 <release>
  return i;
801044a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801044a5:	83 c4 24             	add    $0x24,%esp
801044a8:	5b                   	pop    %ebx
801044a9:	5d                   	pop    %ebp
801044aa:	c3                   	ret    
	...

801044ac <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801044ac:	55                   	push   %ebp
801044ad:	89 e5                	mov    %esp,%ebp
801044af:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801044b2:	9c                   	pushf  
801044b3:	58                   	pop    %eax
801044b4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801044b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801044ba:	c9                   	leave  
801044bb:	c3                   	ret    

801044bc <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
801044bc:	55                   	push   %ebp
801044bd:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801044bf:	fb                   	sti    
}
801044c0:	5d                   	pop    %ebp
801044c1:	c3                   	ret    

801044c2 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
801044c2:	55                   	push   %ebp
801044c3:	89 e5                	mov    %esp,%ebp
801044c5:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
801044c8:	c7 44 24 04 70 a0 10 	movl   $0x8010a070,0x4(%esp)
801044cf:	80 
801044d0:	c7 04 24 c0 62 11 80 	movl   $0x801162c0,(%esp)
801044d7:	e8 ca 12 00 00       	call   801057a6 <initlock>
}
801044dc:	c9                   	leave  
801044dd:	c3                   	ret    

801044de <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
801044de:	55                   	push   %ebp
801044df:	89 e5                	mov    %esp,%ebp
801044e1:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801044e4:	e8 3a 00 00 00       	call   80104523 <mycpu>
801044e9:	89 c2                	mov    %eax,%edx
801044eb:	b8 20 5d 11 80       	mov    $0x80115d20,%eax
801044f0:	29 c2                	sub    %eax,%edx
801044f2:	89 d0                	mov    %edx,%eax
801044f4:	c1 f8 04             	sar    $0x4,%eax
801044f7:	89 c1                	mov    %eax,%ecx
801044f9:	89 ca                	mov    %ecx,%edx
801044fb:	c1 e2 03             	shl    $0x3,%edx
801044fe:	01 ca                	add    %ecx,%edx
80104500:	89 d0                	mov    %edx,%eax
80104502:	c1 e0 05             	shl    $0x5,%eax
80104505:	29 d0                	sub    %edx,%eax
80104507:	c1 e0 02             	shl    $0x2,%eax
8010450a:	01 c8                	add    %ecx,%eax
8010450c:	c1 e0 03             	shl    $0x3,%eax
8010450f:	01 c8                	add    %ecx,%eax
80104511:	89 c2                	mov    %eax,%edx
80104513:	c1 e2 0f             	shl    $0xf,%edx
80104516:	29 c2                	sub    %eax,%edx
80104518:	c1 e2 02             	shl    $0x2,%edx
8010451b:	01 ca                	add    %ecx,%edx
8010451d:	89 d0                	mov    %edx,%eax
8010451f:	f7 d8                	neg    %eax
}
80104521:	c9                   	leave  
80104522:	c3                   	ret    

80104523 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80104523:	55                   	push   %ebp
80104524:	89 e5                	mov    %esp,%ebp
80104526:	83 ec 28             	sub    $0x28,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
80104529:	e8 7e ff ff ff       	call   801044ac <readeflags>
8010452e:	25 00 02 00 00       	and    $0x200,%eax
80104533:	85 c0                	test   %eax,%eax
80104535:	74 0c                	je     80104543 <mycpu+0x20>
    panic("mycpu called with interrupts enabled\n");
80104537:	c7 04 24 78 a0 10 80 	movl   $0x8010a078,(%esp)
8010453e:	e8 11 c0 ff ff       	call   80100554 <panic>
  
  apicid = lapicid();
80104543:	e8 15 ee ff ff       	call   8010335d <lapicid>
80104548:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
8010454b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104552:	eb 3b                	jmp    8010458f <mycpu+0x6c>
    if (cpus[i].apicid == apicid)
80104554:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104557:	89 d0                	mov    %edx,%eax
80104559:	c1 e0 02             	shl    $0x2,%eax
8010455c:	01 d0                	add    %edx,%eax
8010455e:	01 c0                	add    %eax,%eax
80104560:	01 d0                	add    %edx,%eax
80104562:	c1 e0 04             	shl    $0x4,%eax
80104565:	05 20 5d 11 80       	add    $0x80115d20,%eax
8010456a:	8a 00                	mov    (%eax),%al
8010456c:	0f b6 c0             	movzbl %al,%eax
8010456f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80104572:	75 18                	jne    8010458c <mycpu+0x69>
      return &cpus[i];
80104574:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104577:	89 d0                	mov    %edx,%eax
80104579:	c1 e0 02             	shl    $0x2,%eax
8010457c:	01 d0                	add    %edx,%eax
8010457e:	01 c0                	add    %eax,%eax
80104580:	01 d0                	add    %edx,%eax
80104582:	c1 e0 04             	shl    $0x4,%eax
80104585:	05 20 5d 11 80       	add    $0x80115d20,%eax
8010458a:	eb 19                	jmp    801045a5 <mycpu+0x82>
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
8010458c:	ff 45 f4             	incl   -0xc(%ebp)
8010458f:	a1 a0 62 11 80       	mov    0x801162a0,%eax
80104594:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104597:	7c bb                	jl     80104554 <mycpu+0x31>
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
80104599:	c7 04 24 9e a0 10 80 	movl   $0x8010a09e,(%esp)
801045a0:	e8 af bf ff ff       	call   80100554 <panic>
}
801045a5:	c9                   	leave  
801045a6:	c3                   	ret    

801045a7 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
801045a7:	55                   	push   %ebp
801045a8:	89 e5                	mov    %esp,%ebp
801045aa:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
801045ad:	e8 74 13 00 00       	call   80105926 <pushcli>
  c = mycpu();
801045b2:	e8 6c ff ff ff       	call   80104523 <mycpu>
801045b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
801045ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045bd:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801045c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
801045c6:	e8 a5 13 00 00       	call   80105970 <popcli>
  return p;
801045cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801045ce:	c9                   	leave  
801045cf:	c3                   	ret    

801045d0 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801045d0:	55                   	push   %ebp
801045d1:	89 e5                	mov    %esp,%ebp
801045d3:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801045d6:	c7 04 24 c0 62 11 80 	movl   $0x801162c0,(%esp)
801045dd:	e8 e5 11 00 00       	call   801057c7 <acquire>

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801045e2:	c7 45 f4 f4 62 11 80 	movl   $0x801162f4,-0xc(%ebp)
801045e9:	eb 53                	jmp    8010463e <allocproc+0x6e>
    if(p->state == UNUSED)
801045eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ee:	8b 40 0c             	mov    0xc(%eax),%eax
801045f1:	85 c0                	test   %eax,%eax
801045f3:	75 42                	jne    80104637 <allocproc+0x67>
      goto found;
801045f5:	90                   	nop

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801045f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f9:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104600:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80104605:	8d 50 01             	lea    0x1(%eax),%edx
80104608:	89 15 00 d0 10 80    	mov    %edx,0x8010d000
8010460e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104611:	89 42 10             	mov    %eax,0x10(%edx)


  release(&ptable.lock);
80104614:	c7 04 24 c0 62 11 80 	movl   $0x801162c0,(%esp)
8010461b:	e8 11 12 00 00       	call   80105831 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104620:	e8 ec e8 ff ff       	call   80102f11 <kalloc>
80104625:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104628:	89 42 08             	mov    %eax,0x8(%edx)
8010462b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010462e:	8b 40 08             	mov    0x8(%eax),%eax
80104631:	85 c0                	test   %eax,%eax
80104633:	75 39                	jne    8010466e <allocproc+0x9e>
80104635:	eb 26                	jmp    8010465d <allocproc+0x8d>
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104637:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
8010463e:	81 7d f4 f4 84 11 80 	cmpl   $0x801184f4,-0xc(%ebp)
80104645:	72 a4                	jb     801045eb <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
80104647:	c7 04 24 c0 62 11 80 	movl   $0x801162c0,(%esp)
8010464e:	e8 de 11 00 00       	call   80105831 <release>
  return 0;
80104653:	b8 00 00 00 00       	mov    $0x0,%eax
80104658:	e9 83 00 00 00       	jmp    801046e0 <allocproc+0x110>

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
8010465d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104660:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104667:	b8 00 00 00 00       	mov    $0x0,%eax
8010466c:	eb 72                	jmp    801046e0 <allocproc+0x110>
  }
  sp = p->kstack + KSTACKSIZE;
8010466e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104671:	8b 40 08             	mov    0x8(%eax),%eax
80104674:	05 00 10 00 00       	add    $0x1000,%eax
80104679:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010467c:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104680:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104683:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104686:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104689:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
8010468d:	ba cc 75 10 80       	mov    $0x801075cc,%edx
80104692:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104695:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104697:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
8010469b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010469e:	8b 55 f0             	mov    -0x10(%ebp),%edx
801046a1:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801046a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a7:	8b 40 1c             	mov    0x1c(%eax),%eax
801046aa:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801046b1:	00 
801046b2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801046b9:	00 
801046ba:	89 04 24             	mov    %eax,(%esp)
801046bd:	e8 68 13 00 00       	call   80105a2a <memset>
  p->context->eip = (uint)forkret;
801046c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c5:	8b 40 1c             	mov    0x1c(%eax),%eax
801046c8:	ba 88 4e 10 80       	mov    $0x80104e88,%edx
801046cd:	89 50 10             	mov    %edx,0x10(%eax)

  //p->ticks = 0;
  p->cont = NULL;
801046d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d3:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
801046da:	00 00 00 
  // p->usage = 0;
  return p;
801046dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801046e0:	c9                   	leave  
801046e1:	c3                   	ret    

801046e2 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801046e2:	55                   	push   %ebp
801046e3:	89 e5                	mov    %esp,%ebp
801046e5:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
801046e8:	e8 e3 fe ff ff       	call   801045d0 <allocproc>
801046ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
801046f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f3:	a3 60 d9 10 80       	mov    %eax,0x8010d960
  if((p->pgdir = setupkvm()) == 0)
801046f8:	e8 39 44 00 00       	call   80108b36 <setupkvm>
801046fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104700:	89 42 04             	mov    %eax,0x4(%edx)
80104703:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104706:	8b 40 04             	mov    0x4(%eax),%eax
80104709:	85 c0                	test   %eax,%eax
8010470b:	75 0c                	jne    80104719 <userinit+0x37>
    panic("userinit: out of memory?");
8010470d:	c7 04 24 ae a0 10 80 	movl   $0x8010a0ae,(%esp)
80104714:	e8 3b be ff ff       	call   80100554 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104719:	ba 2c 00 00 00       	mov    $0x2c,%edx
8010471e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104721:	8b 40 04             	mov    0x4(%eax),%eax
80104724:	89 54 24 08          	mov    %edx,0x8(%esp)
80104728:	c7 44 24 04 a4 d5 10 	movl   $0x8010d5a4,0x4(%esp)
8010472f:	80 
80104730:	89 04 24             	mov    %eax,(%esp)
80104733:	e8 5f 46 00 00       	call   80108d97 <inituvm>
  p->sz = PGSIZE;
80104738:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010473b:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104741:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104744:	8b 40 18             	mov    0x18(%eax),%eax
80104747:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
8010474e:	00 
8010474f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104756:	00 
80104757:	89 04 24             	mov    %eax,(%esp)
8010475a:	e8 cb 12 00 00       	call   80105a2a <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010475f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104762:	8b 40 18             	mov    0x18(%eax),%eax
80104765:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010476b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010476e:	8b 40 18             	mov    0x18(%eax),%eax
80104771:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010477a:	8b 50 18             	mov    0x18(%eax),%edx
8010477d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104780:	8b 40 18             	mov    0x18(%eax),%eax
80104783:	8b 40 2c             	mov    0x2c(%eax),%eax
80104786:	66 89 42 28          	mov    %ax,0x28(%edx)
  p->tf->ss = p->tf->ds;
8010478a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010478d:	8b 50 18             	mov    0x18(%eax),%edx
80104790:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104793:	8b 40 18             	mov    0x18(%eax),%eax
80104796:	8b 40 2c             	mov    0x2c(%eax),%eax
80104799:	66 89 42 48          	mov    %ax,0x48(%edx)
  p->tf->eflags = FL_IF;
8010479d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047a0:	8b 40 18             	mov    0x18(%eax),%eax
801047a3:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801047aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ad:	8b 40 18             	mov    0x18(%eax),%eax
801047b0:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801047b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ba:	8b 40 18             	mov    0x18(%eax),%eax
801047bd:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801047c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047c7:	83 c0 6c             	add    $0x6c,%eax
801047ca:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801047d1:	00 
801047d2:	c7 44 24 04 c7 a0 10 	movl   $0x8010a0c7,0x4(%esp)
801047d9:	80 
801047da:	89 04 24             	mov    %eax,(%esp)
801047dd:	e8 54 14 00 00       	call   80105c36 <safestrcpy>
  p->cwd = namei("/");
801047e2:	c7 04 24 d0 a0 10 80 	movl   $0x8010a0d0,(%esp)
801047e9:	e8 b4 df ff ff       	call   801027a2 <namei>
801047ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047f1:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
801047f4:	c7 04 24 c0 62 11 80 	movl   $0x801162c0,(%esp)
801047fb:	e8 c7 0f 00 00       	call   801057c7 <acquire>

  p->state = RUNNABLE;
80104800:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104803:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
8010480a:	c7 04 24 c0 62 11 80 	movl   $0x801162c0,(%esp)
80104811:	e8 1b 10 00 00       	call   80105831 <release>
}
80104816:	c9                   	leave  
80104817:	c3                   	ret    

80104818 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104818:	55                   	push   %ebp
80104819:	89 e5                	mov    %esp,%ebp
8010481b:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  struct proc *curproc = myproc();
8010481e:	e8 84 fd ff ff       	call   801045a7 <myproc>
80104823:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80104826:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104829:	8b 00                	mov    (%eax),%eax
8010482b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
8010482e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104832:	7e 31                	jle    80104865 <growproc+0x4d>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104834:	8b 55 08             	mov    0x8(%ebp),%edx
80104837:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010483a:	01 c2                	add    %eax,%edx
8010483c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010483f:	8b 40 04             	mov    0x4(%eax),%eax
80104842:	89 54 24 08          	mov    %edx,0x8(%esp)
80104846:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104849:	89 54 24 04          	mov    %edx,0x4(%esp)
8010484d:	89 04 24             	mov    %eax,(%esp)
80104850:	e8 ad 46 00 00       	call   80108f02 <allocuvm>
80104855:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104858:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010485c:	75 3e                	jne    8010489c <growproc+0x84>
      return -1;
8010485e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104863:	eb 4f                	jmp    801048b4 <growproc+0x9c>
  } else if(n < 0){
80104865:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104869:	79 31                	jns    8010489c <growproc+0x84>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010486b:	8b 55 08             	mov    0x8(%ebp),%edx
8010486e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104871:	01 c2                	add    %eax,%edx
80104873:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104876:	8b 40 04             	mov    0x4(%eax),%eax
80104879:	89 54 24 08          	mov    %edx,0x8(%esp)
8010487d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104880:	89 54 24 04          	mov    %edx,0x4(%esp)
80104884:	89 04 24             	mov    %eax,(%esp)
80104887:	e8 8c 47 00 00       	call   80109018 <deallocuvm>
8010488c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010488f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104893:	75 07                	jne    8010489c <growproc+0x84>
      return -1;
80104895:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010489a:	eb 18                	jmp    801048b4 <growproc+0x9c>
  }
  curproc->sz = sz;
8010489c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010489f:	8b 55 f4             	mov    -0xc(%ebp),%edx
801048a2:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
801048a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048a7:	89 04 24             	mov    %eax,(%esp)
801048aa:	e8 61 43 00 00       	call   80108c10 <switchuvm>
  return 0;
801048af:	b8 00 00 00 00       	mov    $0x0,%eax
}
801048b4:	c9                   	leave  
801048b5:	c3                   	ret    

801048b6 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801048b6:	55                   	push   %ebp
801048b7:	89 e5                	mov    %esp,%ebp
801048b9:	57                   	push   %edi
801048ba:	56                   	push   %esi
801048bb:	53                   	push   %ebx
801048bc:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
801048bf:	e8 e3 fc ff ff       	call   801045a7 <myproc>
801048c4:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
801048c7:	e8 04 fd ff ff       	call   801045d0 <allocproc>
801048cc:	89 45 dc             	mov    %eax,-0x24(%ebp)
801048cf:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801048d3:	75 0a                	jne    801048df <fork+0x29>
    return -1;
801048d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048da:	e9 51 01 00 00       	jmp    80104a30 <fork+0x17a>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801048df:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048e2:	8b 10                	mov    (%eax),%edx
801048e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048e7:	8b 40 04             	mov    0x4(%eax),%eax
801048ea:	89 54 24 04          	mov    %edx,0x4(%esp)
801048ee:	89 04 24             	mov    %eax,(%esp)
801048f1:	e8 c2 48 00 00       	call   801091b8 <copyuvm>
801048f6:	8b 55 dc             	mov    -0x24(%ebp),%edx
801048f9:	89 42 04             	mov    %eax,0x4(%edx)
801048fc:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048ff:	8b 40 04             	mov    0x4(%eax),%eax
80104902:	85 c0                	test   %eax,%eax
80104904:	75 2c                	jne    80104932 <fork+0x7c>
    kfree(np->kstack);
80104906:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104909:	8b 40 08             	mov    0x8(%eax),%eax
8010490c:	89 04 24             	mov    %eax,(%esp)
8010490f:	e8 0f e5 ff ff       	call   80102e23 <kfree>
    np->kstack = 0;
80104914:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104917:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
8010491e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104921:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104928:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010492d:	e9 fe 00 00 00       	jmp    80104a30 <fork+0x17a>
  }
  np->sz = curproc->sz;
80104932:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104935:	8b 10                	mov    (%eax),%edx
80104937:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010493a:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
8010493c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010493f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104942:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80104945:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104948:	8b 50 18             	mov    0x18(%eax),%edx
8010494b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010494e:	8b 40 18             	mov    0x18(%eax),%eax
80104951:	89 c3                	mov    %eax,%ebx
80104953:	b8 13 00 00 00       	mov    $0x13,%eax
80104958:	89 d7                	mov    %edx,%edi
8010495a:	89 de                	mov    %ebx,%esi
8010495c:	89 c1                	mov    %eax,%ecx
8010495e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104960:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104963:	8b 40 18             	mov    0x18(%eax),%eax
80104966:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010496d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104974:	eb 36                	jmp    801049ac <fork+0xf6>
    if(curproc->ofile[i])
80104976:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104979:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010497c:	83 c2 08             	add    $0x8,%edx
8010497f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104983:	85 c0                	test   %eax,%eax
80104985:	74 22                	je     801049a9 <fork+0xf3>
      np->ofile[i] = filedup(curproc->ofile[i]);
80104987:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010498a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010498d:	83 c2 08             	add    $0x8,%edx
80104990:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104994:	89 04 24             	mov    %eax,(%esp)
80104997:	e8 c6 c7 ff ff       	call   80101162 <filedup>
8010499c:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010499f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801049a2:	83 c1 08             	add    $0x8,%ecx
801049a5:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
801049a9:	ff 45 e4             	incl   -0x1c(%ebp)
801049ac:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801049b0:	7e c4                	jle    80104976 <fork+0xc0>
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
801049b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049b5:	8b 40 68             	mov    0x68(%eax),%eax
801049b8:	89 04 24             	mov    %eax,(%esp)
801049bb:	e8 35 d1 ff ff       	call   80101af5 <idup>
801049c0:	8b 55 dc             	mov    -0x24(%ebp),%edx
801049c3:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801049c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049c9:	8d 50 6c             	lea    0x6c(%eax),%edx
801049cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
801049cf:	83 c0 6c             	add    $0x6c,%eax
801049d2:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801049d9:	00 
801049da:	89 54 24 04          	mov    %edx,0x4(%esp)
801049de:	89 04 24             	mov    %eax,(%esp)
801049e1:	e8 50 12 00 00       	call   80105c36 <safestrcpy>



  pid = np->pid;
801049e6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801049e9:	8b 40 10             	mov    0x10(%eax),%eax
801049ec:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
801049ef:	c7 04 24 c0 62 11 80 	movl   $0x801162c0,(%esp)
801049f6:	e8 cc 0d 00 00       	call   801057c7 <acquire>

  np->state = RUNNABLE;
801049fb:	8b 45 dc             	mov    -0x24(%ebp),%eax
801049fe:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  np->ticks = 0;
80104a05:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104a08:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)

  np->cont = curproc->cont;
80104a0f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a12:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104a18:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104a1b:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  //   cprintf("curproc container name is %s.\n", curproc->cont->name);
  //   cprintf("new proc container name is %s.\n", np->cont->name);

  // }

  release(&ptable.lock);
80104a21:	c7 04 24 c0 62 11 80 	movl   $0x801162c0,(%esp)
80104a28:	e8 04 0e 00 00       	call   80105831 <release>

  return pid;
80104a2d:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104a30:	83 c4 2c             	add    $0x2c,%esp
80104a33:	5b                   	pop    %ebx
80104a34:	5e                   	pop    %esi
80104a35:	5f                   	pop    %edi
80104a36:	5d                   	pop    %ebp
80104a37:	c3                   	ret    

80104a38 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104a38:	55                   	push   %ebp
80104a39:	89 e5                	mov    %esp,%ebp
80104a3b:	83 ec 28             	sub    $0x28,%esp
  struct proc *curproc = myproc();
80104a3e:	e8 64 fb ff ff       	call   801045a7 <myproc>
80104a43:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80104a46:	a1 60 d9 10 80       	mov    0x8010d960,%eax
80104a4b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104a4e:	75 0c                	jne    80104a5c <exit+0x24>
    panic("init exiting");
80104a50:	c7 04 24 d2 a0 10 80 	movl   $0x8010a0d2,(%esp)
80104a57:	e8 f8 ba ff ff       	call   80100554 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104a5c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104a63:	eb 3a                	jmp    80104a9f <exit+0x67>
    if(curproc->ofile[fd]){
80104a65:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a68:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a6b:	83 c2 08             	add    $0x8,%edx
80104a6e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a72:	85 c0                	test   %eax,%eax
80104a74:	74 26                	je     80104a9c <exit+0x64>
      fileclose(curproc->ofile[fd]);
80104a76:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a79:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a7c:	83 c2 08             	add    $0x8,%edx
80104a7f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a83:	89 04 24             	mov    %eax,(%esp)
80104a86:	e8 1f c7 ff ff       	call   801011aa <fileclose>
      curproc->ofile[fd] = 0;
80104a8b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a8e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a91:	83 c2 08             	add    $0x8,%edx
80104a94:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104a9b:	00 

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104a9c:	ff 45 f0             	incl   -0x10(%ebp)
80104a9f:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104aa3:	7e c0                	jle    80104a65 <exit+0x2d>
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
80104aa5:	e8 fd ed ff ff       	call   801038a7 <begin_op>
  iput(curproc->cwd);
80104aaa:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104aad:	8b 40 68             	mov    0x68(%eax),%eax
80104ab0:	89 04 24             	mov    %eax,(%esp)
80104ab3:	e8 bd d1 ff ff       	call   80101c75 <iput>
  end_op();
80104ab8:	e8 6c ee ff ff       	call   80103929 <end_op>
  curproc->cwd = 0;
80104abd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ac0:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104ac7:	c7 04 24 c0 62 11 80 	movl   $0x801162c0,(%esp)
80104ace:	e8 f4 0c 00 00       	call   801057c7 <acquire>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104ad3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ad6:	8b 40 14             	mov    0x14(%eax),%eax
80104ad9:	89 04 24             	mov    %eax,(%esp)
80104adc:	e8 7c 04 00 00       	call   80104f5d <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ae1:	c7 45 f4 f4 62 11 80 	movl   $0x801162f4,-0xc(%ebp)
80104ae8:	eb 36                	jmp    80104b20 <exit+0xe8>
    if(p->parent == curproc){
80104aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aed:	8b 40 14             	mov    0x14(%eax),%eax
80104af0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104af3:	75 24                	jne    80104b19 <exit+0xe1>
      p->parent = initproc;
80104af5:	8b 15 60 d9 10 80    	mov    0x8010d960,%edx
80104afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104afe:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b04:	8b 40 0c             	mov    0xc(%eax),%eax
80104b07:	83 f8 05             	cmp    $0x5,%eax
80104b0a:	75 0d                	jne    80104b19 <exit+0xe1>
        wakeup1(initproc);
80104b0c:	a1 60 d9 10 80       	mov    0x8010d960,%eax
80104b11:	89 04 24             	mov    %eax,(%esp)
80104b14:	e8 44 04 00 00       	call   80104f5d <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b19:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104b20:	81 7d f4 f4 84 11 80 	cmpl   $0x801184f4,-0xc(%ebp)
80104b27:	72 c1                	jb     80104aea <exit+0xb2>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104b29:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b2c:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104b33:	e8 70 02 00 00       	call   80104da8 <sched>
  panic("zombie exit");
80104b38:	c7 04 24 df a0 10 80 	movl   $0x8010a0df,(%esp)
80104b3f:	e8 10 ba ff ff       	call   80100554 <panic>

80104b44 <strcmp1>:
}


int
strcmp1(const char *p, const char *q)
{
80104b44:	55                   	push   %ebp
80104b45:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
80104b47:	eb 06                	jmp    80104b4f <strcmp1+0xb>
    p++, q++;
80104b49:	ff 45 08             	incl   0x8(%ebp)
80104b4c:	ff 45 0c             	incl   0xc(%ebp)


int
strcmp1(const char *p, const char *q)
{
  while(*p && *p == *q)
80104b4f:	8b 45 08             	mov    0x8(%ebp),%eax
80104b52:	8a 00                	mov    (%eax),%al
80104b54:	84 c0                	test   %al,%al
80104b56:	74 0e                	je     80104b66 <strcmp1+0x22>
80104b58:	8b 45 08             	mov    0x8(%ebp),%eax
80104b5b:	8a 10                	mov    (%eax),%dl
80104b5d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b60:	8a 00                	mov    (%eax),%al
80104b62:	38 c2                	cmp    %al,%dl
80104b64:	74 e3                	je     80104b49 <strcmp1+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
80104b66:	8b 45 08             	mov    0x8(%ebp),%eax
80104b69:	8a 00                	mov    (%eax),%al
80104b6b:	0f b6 d0             	movzbl %al,%edx
80104b6e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b71:	8a 00                	mov    (%eax),%al
80104b73:	0f b6 c0             	movzbl %al,%eax
80104b76:	29 c2                	sub    %eax,%edx
80104b78:	89 d0                	mov    %edx,%eax
}
80104b7a:	5d                   	pop    %ebp
80104b7b:	c3                   	ret    

80104b7c <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104b7c:	55                   	push   %ebp
80104b7d:	89 e5                	mov    %esp,%ebp
80104b7f:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104b82:	e8 20 fa ff ff       	call   801045a7 <myproc>
80104b87:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104b8a:	c7 04 24 c0 62 11 80 	movl   $0x801162c0,(%esp)
80104b91:	e8 31 0c 00 00       	call   801057c7 <acquire>
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104b96:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b9d:	c7 45 f4 f4 62 11 80 	movl   $0x801162f4,-0xc(%ebp)
80104ba4:	e9 98 00 00 00       	jmp    80104c41 <wait+0xc5>
      if(p->parent != curproc)
80104ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bac:	8b 40 14             	mov    0x14(%eax),%eax
80104baf:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104bb2:	74 05                	je     80104bb9 <wait+0x3d>
        continue;
80104bb4:	e9 81 00 00 00       	jmp    80104c3a <wait+0xbe>
      havekids = 1;
80104bb9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc3:	8b 40 0c             	mov    0xc(%eax),%eax
80104bc6:	83 f8 05             	cmp    $0x5,%eax
80104bc9:	75 6f                	jne    80104c3a <wait+0xbe>
        // Found one.
        pid = p->pid;
80104bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bce:	8b 40 10             	mov    0x10(%eax),%eax
80104bd1:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104bd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd7:	8b 40 08             	mov    0x8(%eax),%eax
80104bda:	89 04 24             	mov    %eax,(%esp)
80104bdd:	e8 41 e2 ff ff       	call   80102e23 <kfree>
        p->kstack = 0;
80104be2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104be5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104bec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bef:	8b 40 04             	mov    0x4(%eax),%eax
80104bf2:	89 04 24             	mov    %eax,(%esp)
80104bf5:	e8 e2 44 00 00       	call   801090dc <freevm>
        p->pid = 0;
80104bfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bfd:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104c04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c07:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104c0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c11:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104c15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c18:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104c1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c22:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104c29:	c7 04 24 c0 62 11 80 	movl   $0x801162c0,(%esp)
80104c30:	e8 fc 0b 00 00       	call   80105831 <release>
        return pid;
80104c35:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104c38:	eb 4f                	jmp    80104c89 <wait+0x10d>
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c3a:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104c41:	81 7d f4 f4 84 11 80 	cmpl   $0x801184f4,-0xc(%ebp)
80104c48:	0f 82 5b ff ff ff    	jb     80104ba9 <wait+0x2d>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104c4e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104c52:	74 0a                	je     80104c5e <wait+0xe2>
80104c54:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c57:	8b 40 24             	mov    0x24(%eax),%eax
80104c5a:	85 c0                	test   %eax,%eax
80104c5c:	74 13                	je     80104c71 <wait+0xf5>
      release(&ptable.lock);
80104c5e:	c7 04 24 c0 62 11 80 	movl   $0x801162c0,(%esp)
80104c65:	e8 c7 0b 00 00       	call   80105831 <release>
      return -1;
80104c6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c6f:	eb 18                	jmp    80104c89 <wait+0x10d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104c71:	c7 44 24 04 c0 62 11 	movl   $0x801162c0,0x4(%esp)
80104c78:	80 
80104c79:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c7c:	89 04 24             	mov    %eax,(%esp)
80104c7f:	e8 43 02 00 00       	call   80104ec7 <sleep>
  }
80104c84:	e9 0d ff ff ff       	jmp    80104b96 <wait+0x1a>
}
80104c89:	c9                   	leave  
80104c8a:	c3                   	ret    

80104c8b <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104c8b:	55                   	push   %ebp
80104c8c:	89 e5                	mov    %esp,%ebp
80104c8e:	83 ec 38             	sub    $0x38,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104c91:	e8 8d f8 ff ff       	call   80104523 <mycpu>
80104c96:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104c99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c9c:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104ca3:	00 00 00 
  char name[16];
  
  for(;;){
    sti();
80104ca6:	e8 11 f8 ff ff       	call   801044bc <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104cab:	c7 04 24 c0 62 11 80 	movl   $0x801162c0,(%esp)
80104cb2:	e8 10 0b 00 00       	call   801057c7 <acquire>
    int holder = get_cticks();
80104cb7:	e8 7e 4d 00 00       	call   80109a3a <get_cticks>
80104cbc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(holder != -1){
80104cbf:	83 7d ec ff          	cmpl   $0xffffffff,-0x14(%ebp)
80104cc3:	74 12                	je     80104cd7 <scheduler+0x4c>
      get_name(holder, &name[0]);
80104cc5:	8d 45 dc             	lea    -0x24(%ebp),%eax
80104cc8:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ccc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ccf:	89 04 24             	mov    %eax,(%esp)
80104cd2:	e8 bf 47 00 00       	call   80109496 <get_name>
    }
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104cd7:	c7 45 f4 f4 62 11 80 	movl   $0x801162f4,-0xc(%ebp)
80104cde:	e9 a7 00 00 00       	jmp    80104d8a <scheduler+0xff>
      if(holder == -1){
80104ce3:	83 7d ec ff          	cmpl   $0xffffffff,-0x14(%ebp)
80104ce7:	75 12                	jne    80104cfb <scheduler+0x70>
        if(p->cont != NULL){
80104ce9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cec:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104cf2:	85 c0                	test   %eax,%eax
80104cf4:	74 35                	je     80104d2b <scheduler+0xa0>
          continue;
80104cf6:	e9 88 00 00 00       	jmp    80104d83 <scheduler+0xf8>
        }
      }
      else{
        if(p->cont == NULL){
80104cfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cfe:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104d04:	85 c0                	test   %eax,%eax
80104d06:	75 02                	jne    80104d0a <scheduler+0x7f>
          continue;
80104d08:	eb 79                	jmp    80104d83 <scheduler+0xf8>
        }
        if(strcmp1(p->cont->name, name) != 0){
80104d0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d0d:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104d13:	8d 50 1c             	lea    0x1c(%eax),%edx
80104d16:	8d 45 dc             	lea    -0x24(%ebp),%eax
80104d19:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d1d:	89 14 24             	mov    %edx,(%esp)
80104d20:	e8 1f fe ff ff       	call   80104b44 <strcmp1>
80104d25:	85 c0                	test   %eax,%eax
80104d27:	74 02                	je     80104d2b <scheduler+0xa0>
          continue;
80104d29:	eb 58                	jmp    80104d83 <scheduler+0xf8>
        }
      }
      if(p->state != RUNNABLE){
80104d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d2e:	8b 40 0c             	mov    0xc(%eax),%eax
80104d31:	83 f8 03             	cmp    $0x3,%eax
80104d34:	74 02                	je     80104d38 <scheduler+0xad>
        continue;
80104d36:	eb 4b                	jmp    80104d83 <scheduler+0xf8>
      // }

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104d38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d3b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d3e:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104d44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d47:	89 04 24             	mov    %eax,(%esp)
80104d4a:	e8 c1 3e 00 00       	call   80108c10 <switchuvm>
      p->state = RUNNING;
80104d4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d52:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&(c->scheduler), p->context);
80104d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d5c:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d5f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d62:	83 c2 04             	add    $0x4,%edx
80104d65:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d69:	89 14 24             	mov    %edx,(%esp)
80104d6c:	e8 33 0f 00 00       	call   80105ca4 <swtch>
      switchkvm();
80104d71:	e8 80 3e 00 00       	call   80108bf6 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104d76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d79:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104d80:	00 00 00 
    acquire(&ptable.lock);
    int holder = get_cticks();
    if(holder != -1){
      get_name(holder, &name[0]);
    }
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d83:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104d8a:	81 7d f4 f4 84 11 80 	cmpl   $0x801184f4,-0xc(%ebp)
80104d91:	0f 82 4c ff ff ff    	jb     80104ce3 <scheduler+0x58>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    release(&ptable.lock);
80104d97:	c7 04 24 c0 62 11 80 	movl   $0x801162c0,(%esp)
80104d9e:	e8 8e 0a 00 00       	call   80105831 <release>
  }
80104da3:	e9 fe fe ff ff       	jmp    80104ca6 <scheduler+0x1b>

80104da8 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104da8:	55                   	push   %ebp
80104da9:	89 e5                	mov    %esp,%ebp
80104dab:	83 ec 28             	sub    $0x28,%esp
  int intena;
  struct proc *p = myproc();
80104dae:	e8 f4 f7 ff ff       	call   801045a7 <myproc>
80104db3:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104db6:	c7 04 24 c0 62 11 80 	movl   $0x801162c0,(%esp)
80104dbd:	e8 33 0b 00 00       	call   801058f5 <holding>
80104dc2:	85 c0                	test   %eax,%eax
80104dc4:	75 0c                	jne    80104dd2 <sched+0x2a>
    panic("sched ptable.lock");
80104dc6:	c7 04 24 eb a0 10 80 	movl   $0x8010a0eb,(%esp)
80104dcd:	e8 82 b7 ff ff       	call   80100554 <panic>
  if(mycpu()->ncli != 1)
80104dd2:	e8 4c f7 ff ff       	call   80104523 <mycpu>
80104dd7:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104ddd:	83 f8 01             	cmp    $0x1,%eax
80104de0:	74 0c                	je     80104dee <sched+0x46>
    panic("sched locks");
80104de2:	c7 04 24 fd a0 10 80 	movl   $0x8010a0fd,(%esp)
80104de9:	e8 66 b7 ff ff       	call   80100554 <panic>
  if(p->state == RUNNING)
80104dee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104df1:	8b 40 0c             	mov    0xc(%eax),%eax
80104df4:	83 f8 04             	cmp    $0x4,%eax
80104df7:	75 0c                	jne    80104e05 <sched+0x5d>
    panic("sched running");
80104df9:	c7 04 24 09 a1 10 80 	movl   $0x8010a109,(%esp)
80104e00:	e8 4f b7 ff ff       	call   80100554 <panic>
  if(readeflags()&FL_IF)
80104e05:	e8 a2 f6 ff ff       	call   801044ac <readeflags>
80104e0a:	25 00 02 00 00       	and    $0x200,%eax
80104e0f:	85 c0                	test   %eax,%eax
80104e11:	74 0c                	je     80104e1f <sched+0x77>
    panic("sched interruptible");
80104e13:	c7 04 24 17 a1 10 80 	movl   $0x8010a117,(%esp)
80104e1a:	e8 35 b7 ff ff       	call   80100554 <panic>
  intena = mycpu()->intena;
80104e1f:	e8 ff f6 ff ff       	call   80104523 <mycpu>
80104e24:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104e2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104e2d:	e8 f1 f6 ff ff       	call   80104523 <mycpu>
80104e32:	8b 40 04             	mov    0x4(%eax),%eax
80104e35:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e38:	83 c2 1c             	add    $0x1c,%edx
80104e3b:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e3f:	89 14 24             	mov    %edx,(%esp)
80104e42:	e8 5d 0e 00 00       	call   80105ca4 <swtch>
  mycpu()->intena = intena;
80104e47:	e8 d7 f6 ff ff       	call   80104523 <mycpu>
80104e4c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104e4f:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104e55:	c9                   	leave  
80104e56:	c3                   	ret    

80104e57 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104e57:	55                   	push   %ebp
80104e58:	89 e5                	mov    %esp,%ebp
80104e5a:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104e5d:	c7 04 24 c0 62 11 80 	movl   $0x801162c0,(%esp)
80104e64:	e8 5e 09 00 00       	call   801057c7 <acquire>
  myproc()->state = RUNNABLE;
80104e69:	e8 39 f7 ff ff       	call   801045a7 <myproc>
80104e6e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104e75:	e8 2e ff ff ff       	call   80104da8 <sched>
  release(&ptable.lock);
80104e7a:	c7 04 24 c0 62 11 80 	movl   $0x801162c0,(%esp)
80104e81:	e8 ab 09 00 00       	call   80105831 <release>
}
80104e86:	c9                   	leave  
80104e87:	c3                   	ret    

80104e88 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104e88:	55                   	push   %ebp
80104e89:	89 e5                	mov    %esp,%ebp
80104e8b:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104e8e:	c7 04 24 c0 62 11 80 	movl   $0x801162c0,(%esp)
80104e95:	e8 97 09 00 00       	call   80105831 <release>

  if (first) {
80104e9a:	a1 04 d0 10 80       	mov    0x8010d004,%eax
80104e9f:	85 c0                	test   %eax,%eax
80104ea1:	74 22                	je     80104ec5 <forkret+0x3d>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104ea3:	c7 05 04 d0 10 80 00 	movl   $0x0,0x8010d004
80104eaa:	00 00 00 
    iinit(ROOTDEV);
80104ead:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104eb4:	e8 a2 c8 ff ff       	call   8010175b <iinit>
    initlog(ROOTDEV);
80104eb9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104ec0:	e8 e3 e7 ff ff       	call   801036a8 <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104ec5:	c9                   	leave  
80104ec6:	c3                   	ret    

80104ec7 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104ec7:	55                   	push   %ebp
80104ec8:	89 e5                	mov    %esp,%ebp
80104eca:	83 ec 28             	sub    $0x28,%esp
  struct proc *p = myproc();
80104ecd:	e8 d5 f6 ff ff       	call   801045a7 <myproc>
80104ed2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104ed5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104ed9:	75 0c                	jne    80104ee7 <sleep+0x20>
    panic("sleep");
80104edb:	c7 04 24 2b a1 10 80 	movl   $0x8010a12b,(%esp)
80104ee2:	e8 6d b6 ff ff       	call   80100554 <panic>

  if(lk == 0)
80104ee7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104eeb:	75 0c                	jne    80104ef9 <sleep+0x32>
    panic("sleep without lk");
80104eed:	c7 04 24 31 a1 10 80 	movl   $0x8010a131,(%esp)
80104ef4:	e8 5b b6 ff ff       	call   80100554 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104ef9:	81 7d 0c c0 62 11 80 	cmpl   $0x801162c0,0xc(%ebp)
80104f00:	74 17                	je     80104f19 <sleep+0x52>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104f02:	c7 04 24 c0 62 11 80 	movl   $0x801162c0,(%esp)
80104f09:	e8 b9 08 00 00       	call   801057c7 <acquire>
    release(lk);
80104f0e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f11:	89 04 24             	mov    %eax,(%esp)
80104f14:	e8 18 09 00 00       	call   80105831 <release>
  }
  // Go to sleep.
  p->chan = chan;
80104f19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f1c:	8b 55 08             	mov    0x8(%ebp),%edx
80104f1f:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104f22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f25:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104f2c:	e8 77 fe ff ff       	call   80104da8 <sched>

  // Tidy up.
  p->chan = 0;
80104f31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f34:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104f3b:	81 7d 0c c0 62 11 80 	cmpl   $0x801162c0,0xc(%ebp)
80104f42:	74 17                	je     80104f5b <sleep+0x94>
    release(&ptable.lock);
80104f44:	c7 04 24 c0 62 11 80 	movl   $0x801162c0,(%esp)
80104f4b:	e8 e1 08 00 00       	call   80105831 <release>
    acquire(lk);
80104f50:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f53:	89 04 24             	mov    %eax,(%esp)
80104f56:	e8 6c 08 00 00       	call   801057c7 <acquire>
  }
}
80104f5b:	c9                   	leave  
80104f5c:	c3                   	ret    

80104f5d <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104f5d:	55                   	push   %ebp
80104f5e:	89 e5                	mov    %esp,%ebp
80104f60:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f63:	c7 45 fc f4 62 11 80 	movl   $0x801162f4,-0x4(%ebp)
80104f6a:	eb 27                	jmp    80104f93 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104f6c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f6f:	8b 40 0c             	mov    0xc(%eax),%eax
80104f72:	83 f8 02             	cmp    $0x2,%eax
80104f75:	75 15                	jne    80104f8c <wakeup1+0x2f>
80104f77:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f7a:	8b 40 20             	mov    0x20(%eax),%eax
80104f7d:	3b 45 08             	cmp    0x8(%ebp),%eax
80104f80:	75 0a                	jne    80104f8c <wakeup1+0x2f>
      p->state = RUNNABLE;
80104f82:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f85:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f8c:	81 45 fc 88 00 00 00 	addl   $0x88,-0x4(%ebp)
80104f93:	81 7d fc f4 84 11 80 	cmpl   $0x801184f4,-0x4(%ebp)
80104f9a:	72 d0                	jb     80104f6c <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104f9c:	c9                   	leave  
80104f9d:	c3                   	ret    

80104f9e <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104f9e:	55                   	push   %ebp
80104f9f:	89 e5                	mov    %esp,%ebp
80104fa1:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104fa4:	c7 04 24 c0 62 11 80 	movl   $0x801162c0,(%esp)
80104fab:	e8 17 08 00 00       	call   801057c7 <acquire>
  wakeup1(chan);
80104fb0:	8b 45 08             	mov    0x8(%ebp),%eax
80104fb3:	89 04 24             	mov    %eax,(%esp)
80104fb6:	e8 a2 ff ff ff       	call   80104f5d <wakeup1>
  release(&ptable.lock);
80104fbb:	c7 04 24 c0 62 11 80 	movl   $0x801162c0,(%esp)
80104fc2:	e8 6a 08 00 00       	call   80105831 <release>
}
80104fc7:	c9                   	leave  
80104fc8:	c3                   	ret    

80104fc9 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104fc9:	55                   	push   %ebp
80104fca:	89 e5                	mov    %esp,%ebp
80104fcc:	53                   	push   %ebx
80104fcd:	83 ec 24             	sub    $0x24,%esp
  struct proc *p;
  
  acquire(&ptable.lock);
80104fd0:	c7 04 24 c0 62 11 80 	movl   $0x801162c0,(%esp)
80104fd7:	e8 eb 07 00 00       	call   801057c7 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fdc:	c7 45 f4 f4 62 11 80 	movl   $0x801162f4,-0xc(%ebp)
80104fe3:	e9 9c 00 00 00       	jmp    80105084 <kill+0xbb>
    if(p->pid == pid){
80104fe8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104feb:	8b 40 10             	mov    0x10(%eax),%eax
80104fee:	3b 45 08             	cmp    0x8(%ebp),%eax
80104ff1:	0f 85 86 00 00 00    	jne    8010507d <kill+0xb4>
      if(myproc()->cont != NULL){
80104ff7:	e8 ab f5 ff ff       	call   801045a7 <myproc>
80104ffc:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105002:	85 c0                	test   %eax,%eax
80105004:	74 45                	je     8010504b <kill+0x82>
        if(p->cont == NULL || strcmp1(myproc()->cont->name, p->cont->name) != 0 ){
80105006:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105009:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010500f:	85 c0                	test   %eax,%eax
80105011:	74 2a                	je     8010503d <kill+0x74>
80105013:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105016:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010501c:	8d 58 1c             	lea    0x1c(%eax),%ebx
8010501f:	e8 83 f5 ff ff       	call   801045a7 <myproc>
80105024:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010502a:	83 c0 1c             	add    $0x1c,%eax
8010502d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80105031:	89 04 24             	mov    %eax,(%esp)
80105034:	e8 0b fb ff ff       	call   80104b44 <strcmp1>
80105039:	85 c0                	test   %eax,%eax
8010503b:	74 0e                	je     8010504b <kill+0x82>
          cprintf(" el oh el You are not authorized to do this.\n");
8010503d:	c7 04 24 44 a1 10 80 	movl   $0x8010a144,(%esp)
80105044:	e8 78 b3 ff ff       	call   801003c1 <cprintf>
          break;
80105049:	eb 46                	jmp    80105091 <kill+0xc8>
        }
      }
      p->killed = 1;
8010504b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010504e:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80105055:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105058:	8b 40 0c             	mov    0xc(%eax),%eax
8010505b:	83 f8 02             	cmp    $0x2,%eax
8010505e:	75 0a                	jne    8010506a <kill+0xa1>
        p->state = RUNNABLE;
80105060:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105063:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
8010506a:	c7 04 24 c0 62 11 80 	movl   $0x801162c0,(%esp)
80105071:	e8 bb 07 00 00       	call   80105831 <release>
      return 0;
80105076:	b8 00 00 00 00       	mov    $0x0,%eax
8010507b:	eb 25                	jmp    801050a2 <kill+0xd9>
kill(int pid)
{
  struct proc *p;
  
  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010507d:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80105084:	81 7d f4 f4 84 11 80 	cmpl   $0x801184f4,-0xc(%ebp)
8010508b:	0f 82 57 ff ff ff    	jb     80104fe8 <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80105091:	c7 04 24 c0 62 11 80 	movl   $0x801162c0,(%esp)
80105098:	e8 94 07 00 00       	call   80105831 <release>
  return -1;
8010509d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801050a2:	83 c4 24             	add    $0x24,%esp
801050a5:	5b                   	pop    %ebx
801050a6:	5d                   	pop    %ebp
801050a7:	c3                   	ret    

801050a8 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801050a8:	55                   	push   %ebp
801050a9:	89 e5                	mov    %esp,%ebp
801050ab:	53                   	push   %ebx
801050ac:	83 ec 64             	sub    $0x64,%esp
  struct proc *p;
  char *state;
  uint pc[10];


  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801050af:	c7 45 f0 f4 62 11 80 	movl   $0x801162f4,-0x10(%ebp)
801050b6:	e9 32 01 00 00       	jmp    801051ed <procdump+0x145>
    if(p->state == UNUSED)
801050bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050be:	8b 40 0c             	mov    0xc(%eax),%eax
801050c1:	85 c0                	test   %eax,%eax
801050c3:	75 05                	jne    801050ca <procdump+0x22>
      continue;
801050c5:	e9 1c 01 00 00       	jmp    801051e6 <procdump+0x13e>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801050ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050cd:	8b 40 0c             	mov    0xc(%eax),%eax
801050d0:	83 f8 05             	cmp    $0x5,%eax
801050d3:	77 23                	ja     801050f8 <procdump+0x50>
801050d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050d8:	8b 40 0c             	mov    0xc(%eax),%eax
801050db:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
801050e2:	85 c0                	test   %eax,%eax
801050e4:	74 12                	je     801050f8 <procdump+0x50>
      state = states[p->state];
801050e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050e9:	8b 40 0c             	mov    0xc(%eax),%eax
801050ec:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
801050f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
801050f6:	eb 07                	jmp    801050ff <procdump+0x57>
    else
      state = "pause";
801050f8:	c7 45 ec 72 a1 10 80 	movl   $0x8010a172,-0x14(%ebp)

    if(p->cont == NULL){
801050ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105102:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105108:	85 c0                	test   %eax,%eax
8010510a:	75 33                	jne    8010513f <procdump+0x97>
      cprintf("%d root %s %s TICKS: %d", p->pid, state, p->name, p->ticks);
8010510c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010510f:	8b 50 7c             	mov    0x7c(%eax),%edx
80105112:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105115:	8d 48 6c             	lea    0x6c(%eax),%ecx
80105118:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010511b:	8b 40 10             	mov    0x10(%eax),%eax
8010511e:	89 54 24 10          	mov    %edx,0x10(%esp)
80105122:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80105126:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105129:	89 54 24 08          	mov    %edx,0x8(%esp)
8010512d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105131:	c7 04 24 78 a1 10 80 	movl   $0x8010a178,(%esp)
80105138:	e8 84 b2 ff ff       	call   801003c1 <cprintf>
8010513d:	eb 41                	jmp    80105180 <procdump+0xd8>
    }
    else{
      cprintf("%d %s %s %s TICKS: %d", p->pid, p->cont->name, state, p->name, p->ticks);
8010513f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105142:	8b 50 7c             	mov    0x7c(%eax),%edx
80105145:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105148:	8d 58 6c             	lea    0x6c(%eax),%ebx
8010514b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010514e:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105154:	8d 48 1c             	lea    0x1c(%eax),%ecx
80105157:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010515a:	8b 40 10             	mov    0x10(%eax),%eax
8010515d:	89 54 24 14          	mov    %edx,0x14(%esp)
80105161:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80105165:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105168:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010516c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105170:	89 44 24 04          	mov    %eax,0x4(%esp)
80105174:	c7 04 24 90 a1 10 80 	movl   $0x8010a190,(%esp)
8010517b:	e8 41 b2 ff ff       	call   801003c1 <cprintf>
    }
    if(p->state == SLEEPING){
80105180:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105183:	8b 40 0c             	mov    0xc(%eax),%eax
80105186:	83 f8 02             	cmp    $0x2,%eax
80105189:	75 4f                	jne    801051da <procdump+0x132>
      getcallerpcs((uint*)p->context->ebp+2, pc);
8010518b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010518e:	8b 40 1c             	mov    0x1c(%eax),%eax
80105191:	8b 40 0c             	mov    0xc(%eax),%eax
80105194:	83 c0 08             	add    $0x8,%eax
80105197:	8d 55 c4             	lea    -0x3c(%ebp),%edx
8010519a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010519e:	89 04 24             	mov    %eax,(%esp)
801051a1:	e8 d8 06 00 00       	call   8010587e <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
801051a6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801051ad:	eb 1a                	jmp    801051c9 <procdump+0x121>
        cprintf(" %p", pc[i]);
801051af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051b2:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801051b6:	89 44 24 04          	mov    %eax,0x4(%esp)
801051ba:	c7 04 24 a6 a1 10 80 	movl   $0x8010a1a6,(%esp)
801051c1:	e8 fb b1 ff ff       	call   801003c1 <cprintf>
    else{
      cprintf("%d %s %s %s TICKS: %d", p->pid, p->cont->name, state, p->name, p->ticks);
    }
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
801051c6:	ff 45 f4             	incl   -0xc(%ebp)
801051c9:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801051cd:	7f 0b                	jg     801051da <procdump+0x132>
801051cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051d2:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801051d6:	85 c0                	test   %eax,%eax
801051d8:	75 d5                	jne    801051af <procdump+0x107>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
801051da:	c7 04 24 aa a1 10 80 	movl   $0x8010a1aa,(%esp)
801051e1:	e8 db b1 ff ff       	call   801003c1 <cprintf>
  struct proc *p;
  char *state;
  uint pc[10];


  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801051e6:	81 45 f0 88 00 00 00 	addl   $0x88,-0x10(%ebp)
801051ed:	81 7d f0 f4 84 11 80 	cmpl   $0x801184f4,-0x10(%ebp)
801051f4:	0f 82 c1 fe ff ff    	jb     801050bb <procdump+0x13>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
801051fa:	83 c4 64             	add    $0x64,%esp
801051fd:	5b                   	pop    %ebx
801051fe:	5d                   	pop    %ebp
801051ff:	c3                   	ret    

80105200 <cstop_container_helper>:


void cstop_container_helper(struct container* cont){
80105200:	55                   	push   %ebp
80105201:	89 e5                	mov    %esp,%ebp
80105203:	83 ec 28             	sub    $0x28,%esp

  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105206:	c7 45 f4 f4 62 11 80 	movl   $0x801162f4,-0xc(%ebp)
8010520d:	eb 37                	jmp    80105246 <cstop_container_helper+0x46>

    if(strcmp1(p->cont->name, cont->name) == 0){
8010520f:	8b 45 08             	mov    0x8(%ebp),%eax
80105212:	8d 50 1c             	lea    0x1c(%eax),%edx
80105215:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105218:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010521e:	83 c0 1c             	add    $0x1c,%eax
80105221:	89 54 24 04          	mov    %edx,0x4(%esp)
80105225:	89 04 24             	mov    %eax,(%esp)
80105228:	e8 17 f9 ff ff       	call   80104b44 <strcmp1>
8010522d:	85 c0                	test   %eax,%eax
8010522f:	75 0e                	jne    8010523f <cstop_container_helper+0x3f>
      kill(p->pid);
80105231:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105234:	8b 40 10             	mov    0x10(%eax),%eax
80105237:	89 04 24             	mov    %eax,(%esp)
8010523a:	e8 8a fd ff ff       	call   80104fc9 <kill>


void cstop_container_helper(struct container* cont){

  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010523f:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80105246:	81 7d f4 f4 84 11 80 	cmpl   $0x801184f4,-0xc(%ebp)
8010524d:	72 c0                	jb     8010520f <cstop_container_helper+0xf>
    if(strcmp1(p->cont->name, cont->name) == 0){
      kill(p->pid);
    }
  }

  container_reset(find(cont->name));
8010524f:	8b 45 08             	mov    0x8(%ebp),%eax
80105252:	83 c0 1c             	add    $0x1c,%eax
80105255:	89 04 24             	mov    %eax,(%esp)
80105258:	e8 54 43 00 00       	call   801095b1 <find>
8010525d:	89 04 24             	mov    %eax,(%esp)
80105260:	e8 93 49 00 00       	call   80109bf8 <container_reset>
}
80105265:	c9                   	leave  
80105266:	c3                   	ret    

80105267 <cstop_helper>:

void cstop_helper(char* name){
80105267:	55                   	push   %ebp
80105268:	89 e5                	mov    %esp,%ebp
8010526a:	83 ec 28             	sub    $0x28,%esp

  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010526d:	c7 45 f4 f4 62 11 80 	movl   $0x801162f4,-0xc(%ebp)
80105274:	eb 69                	jmp    801052df <cstop_helper+0x78>

    if(p->cont == NULL){
80105276:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105279:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010527f:	85 c0                	test   %eax,%eax
80105281:	75 02                	jne    80105285 <cstop_helper+0x1e>
      continue;
80105283:	eb 53                	jmp    801052d8 <cstop_helper+0x71>
    }

    if(strcmp1(p->cont->name, name) == 0){
80105285:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105288:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010528e:	8d 50 1c             	lea    0x1c(%eax),%edx
80105291:	8b 45 08             	mov    0x8(%ebp),%eax
80105294:	89 44 24 04          	mov    %eax,0x4(%esp)
80105298:	89 14 24             	mov    %edx,(%esp)
8010529b:	e8 a4 f8 ff ff       	call   80104b44 <strcmp1>
801052a0:	85 c0                	test   %eax,%eax
801052a2:	75 34                	jne    801052d8 <cstop_helper+0x71>
      cprintf("killing process %s with pid %d\n", p->cont->name, p->pid);
801052a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052a7:	8b 40 10             	mov    0x10(%eax),%eax
801052aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801052ad:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
801052b3:	83 c2 1c             	add    $0x1c,%edx
801052b6:	89 44 24 08          	mov    %eax,0x8(%esp)
801052ba:	89 54 24 04          	mov    %edx,0x4(%esp)
801052be:	c7 04 24 ac a1 10 80 	movl   $0x8010a1ac,(%esp)
801052c5:	e8 f7 b0 ff ff       	call   801003c1 <cprintf>
      kill(p->pid);
801052ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052cd:	8b 40 10             	mov    0x10(%eax),%eax
801052d0:	89 04 24             	mov    %eax,(%esp)
801052d3:	e8 f1 fc ff ff       	call   80104fc9 <kill>

void cstop_helper(char* name){

  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801052d8:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
801052df:	81 7d f4 f4 84 11 80 	cmpl   $0x801184f4,-0xc(%ebp)
801052e6:	72 8e                	jb     80105276 <cstop_helper+0xf>
    if(strcmp1(p->cont->name, name) == 0){
      cprintf("killing process %s with pid %d\n", p->cont->name, p->pid);
      kill(p->pid);
    }
  }
  container_reset(find(name));
801052e8:	8b 45 08             	mov    0x8(%ebp),%eax
801052eb:	89 04 24             	mov    %eax,(%esp)
801052ee:	e8 be 42 00 00       	call   801095b1 <find>
801052f3:	89 04 24             	mov    %eax,(%esp)
801052f6:	e8 fd 48 00 00       	call   80109bf8 <container_reset>
}
801052fb:	c9                   	leave  
801052fc:	c3                   	ret    

801052fd <c_procdump>:

void
c_procdump(char* name)
{
801052fd:	55                   	push   %ebp
801052fe:	89 e5                	mov    %esp,%ebp
80105300:	83 ec 38             	sub    $0x38,%esp
  //int i;
  struct proc *p;
  char *state;
  //uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105303:	c7 45 f4 f4 62 11 80 	movl   $0x801162f4,-0xc(%ebp)
8010530a:	e9 bb 00 00 00       	jmp    801053ca <c_procdump+0xcd>
    if(p->state == UNUSED || p->cont == NULL)
8010530f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105312:	8b 40 0c             	mov    0xc(%eax),%eax
80105315:	85 c0                	test   %eax,%eax
80105317:	74 0d                	je     80105326 <c_procdump+0x29>
80105319:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010531c:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105322:	85 c0                	test   %eax,%eax
80105324:	75 05                	jne    8010532b <c_procdump+0x2e>
      continue;
80105326:	e9 98 00 00 00       	jmp    801053c3 <c_procdump+0xc6>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010532b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010532e:	8b 40 0c             	mov    0xc(%eax),%eax
80105331:	83 f8 06             	cmp    $0x6,%eax
80105334:	77 23                	ja     80105359 <c_procdump+0x5c>
80105336:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105339:	8b 40 0c             	mov    0xc(%eax),%eax
8010533c:	8b 04 85 20 d0 10 80 	mov    -0x7fef2fe0(,%eax,4),%eax
80105343:	85 c0                	test   %eax,%eax
80105345:	74 12                	je     80105359 <c_procdump+0x5c>
      state = states[p->state];
80105347:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010534a:	8b 40 0c             	mov    0xc(%eax),%eax
8010534d:	8b 04 85 20 d0 10 80 	mov    -0x7fef2fe0(,%eax,4),%eax
80105354:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105357:	eb 07                	jmp    80105360 <c_procdump+0x63>
    else
      state = "pause";
80105359:	c7 45 f0 72 a1 10 80 	movl   $0x8010a172,-0x10(%ebp)

    if(strcmp1(p->cont->name, name) == 0){
80105360:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105363:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105369:	8d 50 1c             	lea    0x1c(%eax),%edx
8010536c:	8b 45 08             	mov    0x8(%ebp),%eax
8010536f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105373:	89 14 24             	mov    %edx,(%esp)
80105376:	e8 c9 f7 ff ff       	call   80104b44 <strcmp1>
8010537b:	85 c0                	test   %eax,%eax
8010537d:	75 44                	jne    801053c3 <c_procdump+0xc6>
      cprintf("     Container: %s Process: %s PID: %d State: %s Ticks: %d", 
8010537f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105382:	8b 50 7c             	mov    0x7c(%eax),%edx
80105385:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105388:	8b 40 10             	mov    0x10(%eax),%eax
        name, p->name, p->pid, state, p->ticks);
8010538b:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010538e:	83 c1 6c             	add    $0x6c,%ecx
      state = states[p->state];
    else
      state = "pause";

    if(strcmp1(p->cont->name, name) == 0){
      cprintf("     Container: %s Process: %s PID: %d State: %s Ticks: %d", 
80105391:	89 54 24 14          	mov    %edx,0x14(%esp)
80105395:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105398:	89 54 24 10          	mov    %edx,0x10(%esp)
8010539c:	89 44 24 0c          	mov    %eax,0xc(%esp)
801053a0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801053a4:	8b 45 08             	mov    0x8(%ebp),%eax
801053a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801053ab:	c7 04 24 cc a1 10 80 	movl   $0x8010a1cc,(%esp)
801053b2:	e8 0a b0 ff ff       	call   801003c1 <cprintf>
        name, p->name, p->pid, state, p->ticks);
      cprintf("\n");
801053b7:	c7 04 24 aa a1 10 80 	movl   $0x8010a1aa,(%esp)
801053be:	e8 fe af ff ff       	call   801003c1 <cprintf>
  //int i;
  struct proc *p;
  char *state;
  //uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801053c3:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
801053ca:	81 7d f4 f4 84 11 80 	cmpl   $0x801184f4,-0xc(%ebp)
801053d1:	0f 82 38 ff ff ff    	jb     8010530f <c_procdump+0x12>
      cprintf("     Container: %s Process: %s PID: %d State: %s Ticks: %d", 
        name, p->name, p->pid, state, p->ticks);
      cprintf("\n");
    }  
  }
}
801053d7:	c9                   	leave  
801053d8:	c3                   	ret    

801053d9 <c_proc_data>:

void
c_proc_data(char* name)
{
801053d9:	55                   	push   %ebp
801053da:	89 e5                	mov    %esp,%ebp
801053dc:	56                   	push   %esi
801053dd:	53                   	push   %ebx
801053de:	83 ec 30             	sub    $0x30,%esp
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie",
  [PAUSE]     "pause "
  };
  int total = 0;
801053e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  struct proc *p;
  struct proc *x;
  char *state;
  acquire(&ptable.lock);
801053e8:	c7 04 24 c0 62 11 80 	movl   $0x801162c0,(%esp)
801053ef:	e8 d3 03 00 00       	call   801057c7 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801053f4:	c7 45 f0 f4 62 11 80 	movl   $0x801162f4,-0x10(%ebp)
801053fb:	e9 82 00 00 00       	jmp    80105482 <c_proc_data+0xa9>
    if(p->state == UNUSED || p->cont == NULL)
80105400:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105403:	8b 40 0c             	mov    0xc(%eax),%eax
80105406:	85 c0                	test   %eax,%eax
80105408:	74 0d                	je     80105417 <c_proc_data+0x3e>
8010540a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010540d:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105413:	85 c0                	test   %eax,%eax
80105415:	75 02                	jne    80105419 <c_proc_data+0x40>
      continue;
80105417:	eb 62                	jmp    8010547b <c_proc_data+0xa2>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105419:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010541c:	8b 40 0c             	mov    0xc(%eax),%eax
8010541f:	83 f8 06             	cmp    $0x6,%eax
80105422:	77 23                	ja     80105447 <c_proc_data+0x6e>
80105424:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105427:	8b 40 0c             	mov    0xc(%eax),%eax
8010542a:	8b 04 85 3c d0 10 80 	mov    -0x7fef2fc4(,%eax,4),%eax
80105431:	85 c0                	test   %eax,%eax
80105433:	74 12                	je     80105447 <c_proc_data+0x6e>
      state = states[p->state];
80105435:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105438:	8b 40 0c             	mov    0xc(%eax),%eax
8010543b:	8b 04 85 3c d0 10 80 	mov    -0x7fef2fc4(,%eax,4),%eax
80105442:	89 45 e8             	mov    %eax,-0x18(%ebp)
80105445:	eb 07                	jmp    8010544e <c_proc_data+0x75>
    else
      state = "pause";
80105447:	c7 45 e8 72 a1 10 80 	movl   $0x8010a172,-0x18(%ebp)

    if(strcmp1(p->cont->name, name) == 0){
8010544e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105451:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105457:	8d 50 1c             	lea    0x1c(%eax),%edx
8010545a:	8b 45 08             	mov    0x8(%ebp),%eax
8010545d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105461:	89 14 24             	mov    %edx,(%esp)
80105464:	e8 db f6 ff ff       	call   80104b44 <strcmp1>
80105469:	85 c0                	test   %eax,%eax
8010546b:	75 0e                	jne    8010547b <c_proc_data+0xa2>
      total += p->ticks;
8010546d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105470:	8b 50 7c             	mov    0x7c(%eax),%edx
80105473:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105476:	01 d0                	add    %edx,%eax
80105478:	89 45 f4             	mov    %eax,-0xc(%ebp)
  int total = 0;
  struct proc *p;
  struct proc *x;
  char *state;
  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010547b:	81 45 f0 88 00 00 00 	addl   $0x88,-0x10(%ebp)
80105482:	81 7d f0 f4 84 11 80 	cmpl   $0x801184f4,-0x10(%ebp)
80105489:	0f 82 71 ff ff ff    	jb     80105400 <c_proc_data+0x27>

    if(strcmp1(p->cont->name, name) == 0){
      total += p->ticks;
    }
  }
  release(&ptable.lock);
8010548f:	c7 04 24 c0 62 11 80 	movl   $0x801162c0,(%esp)
80105496:	e8 96 03 00 00       	call   80105831 <release>

  for(x = ptable.proc; x < &ptable.proc[NPROC]; x++){
8010549b:	c7 45 ec f4 62 11 80 	movl   $0x801162f4,-0x14(%ebp)
801054a2:	e9 dd 00 00 00       	jmp    80105584 <c_proc_data+0x1ab>
    if(x->state == UNUSED || x->cont == NULL)
801054a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801054aa:	8b 40 0c             	mov    0xc(%eax),%eax
801054ad:	85 c0                	test   %eax,%eax
801054af:	74 0d                	je     801054be <c_proc_data+0xe5>
801054b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801054b4:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801054ba:	85 c0                	test   %eax,%eax
801054bc:	75 05                	jne    801054c3 <c_proc_data+0xea>
      continue;
801054be:	e9 ba 00 00 00       	jmp    8010557d <c_proc_data+0x1a4>
    if(x->state >= 0 && x->state < NELEM(states) && states[x->state])
801054c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801054c6:	8b 40 0c             	mov    0xc(%eax),%eax
801054c9:	83 f8 06             	cmp    $0x6,%eax
801054cc:	77 23                	ja     801054f1 <c_proc_data+0x118>
801054ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
801054d1:	8b 40 0c             	mov    0xc(%eax),%eax
801054d4:	8b 04 85 3c d0 10 80 	mov    -0x7fef2fc4(,%eax,4),%eax
801054db:	85 c0                	test   %eax,%eax
801054dd:	74 12                	je     801054f1 <c_proc_data+0x118>
      state = states[x->state];
801054df:	8b 45 ec             	mov    -0x14(%ebp),%eax
801054e2:	8b 40 0c             	mov    0xc(%eax),%eax
801054e5:	8b 04 85 3c d0 10 80 	mov    -0x7fef2fc4(,%eax,4),%eax
801054ec:	89 45 e8             	mov    %eax,-0x18(%ebp)
801054ef:	eb 07                	jmp    801054f8 <c_proc_data+0x11f>
    else
      state = "pause";
801054f1:	c7 45 e8 72 a1 10 80 	movl   $0x8010a172,-0x18(%ebp)

    if(strcmp1(x->cont->name, name) == 0){
801054f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801054fb:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105501:	8d 50 1c             	lea    0x1c(%eax),%edx
80105504:	8b 45 08             	mov    0x8(%ebp),%eax
80105507:	89 44 24 04          	mov    %eax,0x4(%esp)
8010550b:	89 14 24             	mov    %edx,(%esp)
8010550e:	e8 31 f6 ff ff       	call   80104b44 <strcmp1>
80105513:	85 c0                	test   %eax,%eax
80105515:	75 66                	jne    8010557d <c_proc_data+0x1a4>
      cprintf("     Process: %s PID: %d State: %s Ticks: %d CPU Consumption: %d%%", 
        x->name, x->pid, state, x->ticks, (x->ticks*100/total));
80105517:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010551a:	8b 50 7c             	mov    0x7c(%eax),%edx
8010551d:	89 d0                	mov    %edx,%eax
8010551f:	c1 e0 02             	shl    $0x2,%eax
80105522:	01 d0                	add    %edx,%eax
80105524:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010552b:	01 d0                	add    %edx,%eax
8010552d:	c1 e0 02             	shl    $0x2,%eax
      state = states[x->state];
    else
      state = "pause";

    if(strcmp1(x->cont->name, name) == 0){
      cprintf("     Process: %s PID: %d State: %s Ticks: %d CPU Consumption: %d%%", 
80105530:	8b 75 f4             	mov    -0xc(%ebp),%esi
80105533:	ba 00 00 00 00       	mov    $0x0,%edx
80105538:	f7 f6                	div    %esi
8010553a:	89 c1                	mov    %eax,%ecx
8010553c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010553f:	8b 50 7c             	mov    0x7c(%eax),%edx
80105542:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105545:	8b 40 10             	mov    0x10(%eax),%eax
        x->name, x->pid, state, x->ticks, (x->ticks*100/total));
80105548:	8b 5d ec             	mov    -0x14(%ebp),%ebx
8010554b:	83 c3 6c             	add    $0x6c,%ebx
      state = states[x->state];
    else
      state = "pause";

    if(strcmp1(x->cont->name, name) == 0){
      cprintf("     Process: %s PID: %d State: %s Ticks: %d CPU Consumption: %d%%", 
8010554e:	89 4c 24 14          	mov    %ecx,0x14(%esp)
80105552:	89 54 24 10          	mov    %edx,0x10(%esp)
80105556:	8b 55 e8             	mov    -0x18(%ebp),%edx
80105559:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010555d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105561:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80105565:	c7 04 24 08 a2 10 80 	movl   $0x8010a208,(%esp)
8010556c:	e8 50 ae ff ff       	call   801003c1 <cprintf>
        x->name, x->pid, state, x->ticks, (x->ticks*100/total));
      cprintf("\n");
80105571:	c7 04 24 aa a1 10 80 	movl   $0x8010a1aa,(%esp)
80105578:	e8 44 ae ff ff       	call   801003c1 <cprintf>
      total += p->ticks;
    }
  }
  release(&ptable.lock);

  for(x = ptable.proc; x < &ptable.proc[NPROC]; x++){
8010557d:	81 45 ec 88 00 00 00 	addl   $0x88,-0x14(%ebp)
80105584:	81 7d ec f4 84 11 80 	cmpl   $0x801184f4,-0x14(%ebp)
8010558b:	0f 82 16 ff ff ff    	jb     801054a7 <c_proc_data+0xce>
      cprintf("     Process: %s PID: %d State: %s Ticks: %d CPU Consumption: %d%%", 
        x->name, x->pid, state, x->ticks, (x->ticks*100/total));
      cprintf("\n");
    }  
  }
}
80105591:	83 c4 30             	add    $0x30,%esp
80105594:	5b                   	pop    %ebx
80105595:	5e                   	pop    %esi
80105596:	5d                   	pop    %ebp
80105597:	c3                   	ret    

80105598 <pause>:

void
pause(char* name)
{
80105598:	55                   	push   %ebp
80105599:	89 e5                	mov    %esp,%ebp
8010559b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010559e:	c7 45 fc f4 62 11 80 	movl   $0x801162f4,-0x4(%ebp)
801055a5:	eb 49                	jmp    801055f0 <pause+0x58>
    if(p->state == UNUSED || p->cont == NULL)
801055a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055aa:	8b 40 0c             	mov    0xc(%eax),%eax
801055ad:	85 c0                	test   %eax,%eax
801055af:	74 0d                	je     801055be <pause+0x26>
801055b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055b4:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801055ba:	85 c0                	test   %eax,%eax
801055bc:	75 02                	jne    801055c0 <pause+0x28>
      continue;
801055be:	eb 29                	jmp    801055e9 <pause+0x51>
    if(strcmp1(p->cont->name, name) == 0){
801055c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055c3:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801055c9:	8d 50 1c             	lea    0x1c(%eax),%edx
801055cc:	8b 45 08             	mov    0x8(%ebp),%eax
801055cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801055d3:	89 14 24             	mov    %edx,(%esp)
801055d6:	e8 69 f5 ff ff       	call   80104b44 <strcmp1>
801055db:	85 c0                	test   %eax,%eax
801055dd:	75 0a                	jne    801055e9 <pause+0x51>
      p->state = PAUSE;
801055df:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055e2:	c7 40 0c 06 00 00 00 	movl   $0x6,0xc(%eax)
void
pause(char* name)
{
  struct proc *p;
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801055e9:	81 45 fc 88 00 00 00 	addl   $0x88,-0x4(%ebp)
801055f0:	81 7d fc f4 84 11 80 	cmpl   $0x801184f4,-0x4(%ebp)
801055f7:	72 ae                	jb     801055a7 <pause+0xf>
      continue;
    if(strcmp1(p->cont->name, name) == 0){
      p->state = PAUSE;
    }
  }
}
801055f9:	c9                   	leave  
801055fa:	c3                   	ret    

801055fb <resume>:

void
resume(char* name)
{
801055fb:	55                   	push   %ebp
801055fc:	89 e5                	mov    %esp,%ebp
801055fe:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105601:	c7 45 fc f4 62 11 80 	movl   $0x801162f4,-0x4(%ebp)
80105608:	eb 3b                	jmp    80105645 <resume+0x4a>
    if(p->state == PAUSE){
8010560a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010560d:	8b 40 0c             	mov    0xc(%eax),%eax
80105610:	83 f8 06             	cmp    $0x6,%eax
80105613:	75 29                	jne    8010563e <resume+0x43>
      if(strcmp1(p->cont->name, name) == 0){
80105615:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105618:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010561e:	8d 50 1c             	lea    0x1c(%eax),%edx
80105621:	8b 45 08             	mov    0x8(%ebp),%eax
80105624:	89 44 24 04          	mov    %eax,0x4(%esp)
80105628:	89 14 24             	mov    %edx,(%esp)
8010562b:	e8 14 f5 ff ff       	call   80104b44 <strcmp1>
80105630:	85 c0                	test   %eax,%eax
80105632:	75 0a                	jne    8010563e <resume+0x43>
        p->state = RUNNABLE;
80105634:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105637:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
void
resume(char* name)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010563e:	81 45 fc 88 00 00 00 	addl   $0x88,-0x4(%ebp)
80105645:	81 7d fc f4 84 11 80 	cmpl   $0x801184f4,-0x4(%ebp)
8010564c:	72 bc                	jb     8010560a <resume+0xf>
      if(strcmp1(p->cont->name, name) == 0){
        p->state = RUNNABLE;
      }
    }
  }
}
8010564e:	c9                   	leave  
8010564f:	c3                   	ret    

80105650 <initp>:


struct proc* initp(void){
80105650:	55                   	push   %ebp
80105651:	89 e5                	mov    %esp,%ebp
  return initproc;
80105653:	a1 60 d9 10 80       	mov    0x8010d960,%eax
}
80105658:	5d                   	pop    %ebp
80105659:	c3                   	ret    

8010565a <c_proc>:

struct proc* c_proc(void){
8010565a:	55                   	push   %ebp
8010565b:	89 e5                	mov    %esp,%ebp
8010565d:	83 ec 08             	sub    $0x8,%esp
  return myproc();
80105660:	e8 42 ef ff ff       	call   801045a7 <myproc>
}
80105665:	c9                   	leave  
80105666:	c3                   	ret    
	...

80105668 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80105668:	55                   	push   %ebp
80105669:	89 e5                	mov    %esp,%ebp
8010566b:	83 ec 18             	sub    $0x18,%esp
  initlock(&lk->lk, "sleep lock");
8010566e:	8b 45 08             	mov    0x8(%ebp),%eax
80105671:	83 c0 04             	add    $0x4,%eax
80105674:	c7 44 24 04 7c a2 10 	movl   $0x8010a27c,0x4(%esp)
8010567b:	80 
8010567c:	89 04 24             	mov    %eax,(%esp)
8010567f:	e8 22 01 00 00       	call   801057a6 <initlock>
  lk->name = name;
80105684:	8b 45 08             	mov    0x8(%ebp),%eax
80105687:	8b 55 0c             	mov    0xc(%ebp),%edx
8010568a:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
8010568d:	8b 45 08             	mov    0x8(%ebp),%eax
80105690:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80105696:	8b 45 08             	mov    0x8(%ebp),%eax
80105699:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
801056a0:	c9                   	leave  
801056a1:	c3                   	ret    

801056a2 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801056a2:	55                   	push   %ebp
801056a3:	89 e5                	mov    %esp,%ebp
801056a5:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
801056a8:	8b 45 08             	mov    0x8(%ebp),%eax
801056ab:	83 c0 04             	add    $0x4,%eax
801056ae:	89 04 24             	mov    %eax,(%esp)
801056b1:	e8 11 01 00 00       	call   801057c7 <acquire>
  while (lk->locked) {
801056b6:	eb 15                	jmp    801056cd <acquiresleep+0x2b>
    sleep(lk, &lk->lk);
801056b8:	8b 45 08             	mov    0x8(%ebp),%eax
801056bb:	83 c0 04             	add    $0x4,%eax
801056be:	89 44 24 04          	mov    %eax,0x4(%esp)
801056c2:	8b 45 08             	mov    0x8(%ebp),%eax
801056c5:	89 04 24             	mov    %eax,(%esp)
801056c8:	e8 fa f7 ff ff       	call   80104ec7 <sleep>

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
801056cd:	8b 45 08             	mov    0x8(%ebp),%eax
801056d0:	8b 00                	mov    (%eax),%eax
801056d2:	85 c0                	test   %eax,%eax
801056d4:	75 e2                	jne    801056b8 <acquiresleep+0x16>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
801056d6:	8b 45 08             	mov    0x8(%ebp),%eax
801056d9:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
801056df:	e8 c3 ee ff ff       	call   801045a7 <myproc>
801056e4:	8b 50 10             	mov    0x10(%eax),%edx
801056e7:	8b 45 08             	mov    0x8(%ebp),%eax
801056ea:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
801056ed:	8b 45 08             	mov    0x8(%ebp),%eax
801056f0:	83 c0 04             	add    $0x4,%eax
801056f3:	89 04 24             	mov    %eax,(%esp)
801056f6:	e8 36 01 00 00       	call   80105831 <release>
}
801056fb:	c9                   	leave  
801056fc:	c3                   	ret    

801056fd <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801056fd:	55                   	push   %ebp
801056fe:	89 e5                	mov    %esp,%ebp
80105700:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
80105703:	8b 45 08             	mov    0x8(%ebp),%eax
80105706:	83 c0 04             	add    $0x4,%eax
80105709:	89 04 24             	mov    %eax,(%esp)
8010570c:	e8 b6 00 00 00       	call   801057c7 <acquire>
  lk->locked = 0;
80105711:	8b 45 08             	mov    0x8(%ebp),%eax
80105714:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010571a:	8b 45 08             	mov    0x8(%ebp),%eax
8010571d:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80105724:	8b 45 08             	mov    0x8(%ebp),%eax
80105727:	89 04 24             	mov    %eax,(%esp)
8010572a:	e8 6f f8 ff ff       	call   80104f9e <wakeup>
  release(&lk->lk);
8010572f:	8b 45 08             	mov    0x8(%ebp),%eax
80105732:	83 c0 04             	add    $0x4,%eax
80105735:	89 04 24             	mov    %eax,(%esp)
80105738:	e8 f4 00 00 00       	call   80105831 <release>
}
8010573d:	c9                   	leave  
8010573e:	c3                   	ret    

8010573f <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
8010573f:	55                   	push   %ebp
80105740:	89 e5                	mov    %esp,%ebp
80105742:	83 ec 28             	sub    $0x28,%esp
  int r;
  
  acquire(&lk->lk);
80105745:	8b 45 08             	mov    0x8(%ebp),%eax
80105748:	83 c0 04             	add    $0x4,%eax
8010574b:	89 04 24             	mov    %eax,(%esp)
8010574e:	e8 74 00 00 00       	call   801057c7 <acquire>
  r = lk->locked;
80105753:	8b 45 08             	mov    0x8(%ebp),%eax
80105756:	8b 00                	mov    (%eax),%eax
80105758:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
8010575b:	8b 45 08             	mov    0x8(%ebp),%eax
8010575e:	83 c0 04             	add    $0x4,%eax
80105761:	89 04 24             	mov    %eax,(%esp)
80105764:	e8 c8 00 00 00       	call   80105831 <release>
  return r;
80105769:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010576c:	c9                   	leave  
8010576d:	c3                   	ret    
	...

80105770 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105770:	55                   	push   %ebp
80105771:	89 e5                	mov    %esp,%ebp
80105773:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105776:	9c                   	pushf  
80105777:	58                   	pop    %eax
80105778:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010577b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010577e:	c9                   	leave  
8010577f:	c3                   	ret    

80105780 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105780:	55                   	push   %ebp
80105781:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105783:	fa                   	cli    
}
80105784:	5d                   	pop    %ebp
80105785:	c3                   	ret    

80105786 <sti>:

static inline void
sti(void)
{
80105786:	55                   	push   %ebp
80105787:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105789:	fb                   	sti    
}
8010578a:	5d                   	pop    %ebp
8010578b:	c3                   	ret    

8010578c <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010578c:	55                   	push   %ebp
8010578d:	89 e5                	mov    %esp,%ebp
8010578f:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105792:	8b 55 08             	mov    0x8(%ebp),%edx
80105795:	8b 45 0c             	mov    0xc(%ebp),%eax
80105798:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010579b:	f0 87 02             	lock xchg %eax,(%edx)
8010579e:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801057a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801057a4:	c9                   	leave  
801057a5:	c3                   	ret    

801057a6 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801057a6:	55                   	push   %ebp
801057a7:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801057a9:	8b 45 08             	mov    0x8(%ebp),%eax
801057ac:	8b 55 0c             	mov    0xc(%ebp),%edx
801057af:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801057b2:	8b 45 08             	mov    0x8(%ebp),%eax
801057b5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801057bb:	8b 45 08             	mov    0x8(%ebp),%eax
801057be:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801057c5:	5d                   	pop    %ebp
801057c6:	c3                   	ret    

801057c7 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801057c7:	55                   	push   %ebp
801057c8:	89 e5                	mov    %esp,%ebp
801057ca:	53                   	push   %ebx
801057cb:	83 ec 14             	sub    $0x14,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801057ce:	e8 53 01 00 00       	call   80105926 <pushcli>
  if(holding(lk))
801057d3:	8b 45 08             	mov    0x8(%ebp),%eax
801057d6:	89 04 24             	mov    %eax,(%esp)
801057d9:	e8 17 01 00 00       	call   801058f5 <holding>
801057de:	85 c0                	test   %eax,%eax
801057e0:	74 0c                	je     801057ee <acquire+0x27>
    panic("acquire");
801057e2:	c7 04 24 87 a2 10 80 	movl   $0x8010a287,(%esp)
801057e9:	e8 66 ad ff ff       	call   80100554 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
801057ee:	90                   	nop
801057ef:	8b 45 08             	mov    0x8(%ebp),%eax
801057f2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801057f9:	00 
801057fa:	89 04 24             	mov    %eax,(%esp)
801057fd:	e8 8a ff ff ff       	call   8010578c <xchg>
80105802:	85 c0                	test   %eax,%eax
80105804:	75 e9                	jne    801057ef <acquire+0x28>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80105806:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
8010580b:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010580e:	e8 10 ed ff ff       	call   80104523 <mycpu>
80105813:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80105816:	8b 45 08             	mov    0x8(%ebp),%eax
80105819:	83 c0 0c             	add    $0xc,%eax
8010581c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105820:	8d 45 08             	lea    0x8(%ebp),%eax
80105823:	89 04 24             	mov    %eax,(%esp)
80105826:	e8 53 00 00 00       	call   8010587e <getcallerpcs>
}
8010582b:	83 c4 14             	add    $0x14,%esp
8010582e:	5b                   	pop    %ebx
8010582f:	5d                   	pop    %ebp
80105830:	c3                   	ret    

80105831 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105831:	55                   	push   %ebp
80105832:	89 e5                	mov    %esp,%ebp
80105834:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80105837:	8b 45 08             	mov    0x8(%ebp),%eax
8010583a:	89 04 24             	mov    %eax,(%esp)
8010583d:	e8 b3 00 00 00       	call   801058f5 <holding>
80105842:	85 c0                	test   %eax,%eax
80105844:	75 0c                	jne    80105852 <release+0x21>
    panic("release");
80105846:	c7 04 24 8f a2 10 80 	movl   $0x8010a28f,(%esp)
8010584d:	e8 02 ad ff ff       	call   80100554 <panic>

  lk->pcs[0] = 0;
80105852:	8b 45 08             	mov    0x8(%ebp),%eax
80105855:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010585c:	8b 45 08             	mov    0x8(%ebp),%eax
8010585f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80105866:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
8010586b:	8b 45 08             	mov    0x8(%ebp),%eax
8010586e:	8b 55 08             	mov    0x8(%ebp),%edx
80105871:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80105877:	e8 f4 00 00 00       	call   80105970 <popcli>
}
8010587c:	c9                   	leave  
8010587d:	c3                   	ret    

8010587e <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010587e:	55                   	push   %ebp
8010587f:	89 e5                	mov    %esp,%ebp
80105881:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80105884:	8b 45 08             	mov    0x8(%ebp),%eax
80105887:	83 e8 08             	sub    $0x8,%eax
8010588a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010588d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105894:	eb 37                	jmp    801058cd <getcallerpcs+0x4f>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105896:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010589a:	74 37                	je     801058d3 <getcallerpcs+0x55>
8010589c:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801058a3:	76 2e                	jbe    801058d3 <getcallerpcs+0x55>
801058a5:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801058a9:	74 28                	je     801058d3 <getcallerpcs+0x55>
      break;
    pcs[i] = ebp[1];     // saved %eip
801058ab:	8b 45 f8             	mov    -0x8(%ebp),%eax
801058ae:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801058b5:	8b 45 0c             	mov    0xc(%ebp),%eax
801058b8:	01 c2                	add    %eax,%edx
801058ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058bd:	8b 40 04             	mov    0x4(%eax),%eax
801058c0:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801058c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058c5:	8b 00                	mov    (%eax),%eax
801058c7:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801058ca:	ff 45 f8             	incl   -0x8(%ebp)
801058cd:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801058d1:	7e c3                	jle    80105896 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801058d3:	eb 18                	jmp    801058ed <getcallerpcs+0x6f>
    pcs[i] = 0;
801058d5:	8b 45 f8             	mov    -0x8(%ebp),%eax
801058d8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801058df:	8b 45 0c             	mov    0xc(%ebp),%eax
801058e2:	01 d0                	add    %edx,%eax
801058e4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801058ea:	ff 45 f8             	incl   -0x8(%ebp)
801058ed:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801058f1:	7e e2                	jle    801058d5 <getcallerpcs+0x57>
    pcs[i] = 0;
}
801058f3:	c9                   	leave  
801058f4:	c3                   	ret    

801058f5 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801058f5:	55                   	push   %ebp
801058f6:	89 e5                	mov    %esp,%ebp
801058f8:	53                   	push   %ebx
801058f9:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
801058fc:	8b 45 08             	mov    0x8(%ebp),%eax
801058ff:	8b 00                	mov    (%eax),%eax
80105901:	85 c0                	test   %eax,%eax
80105903:	74 16                	je     8010591b <holding+0x26>
80105905:	8b 45 08             	mov    0x8(%ebp),%eax
80105908:	8b 58 08             	mov    0x8(%eax),%ebx
8010590b:	e8 13 ec ff ff       	call   80104523 <mycpu>
80105910:	39 c3                	cmp    %eax,%ebx
80105912:	75 07                	jne    8010591b <holding+0x26>
80105914:	b8 01 00 00 00       	mov    $0x1,%eax
80105919:	eb 05                	jmp    80105920 <holding+0x2b>
8010591b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105920:	83 c4 04             	add    $0x4,%esp
80105923:	5b                   	pop    %ebx
80105924:	5d                   	pop    %ebp
80105925:	c3                   	ret    

80105926 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105926:	55                   	push   %ebp
80105927:	89 e5                	mov    %esp,%ebp
80105929:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
8010592c:	e8 3f fe ff ff       	call   80105770 <readeflags>
80105931:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80105934:	e8 47 fe ff ff       	call   80105780 <cli>
  if(mycpu()->ncli == 0)
80105939:	e8 e5 eb ff ff       	call   80104523 <mycpu>
8010593e:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105944:	85 c0                	test   %eax,%eax
80105946:	75 14                	jne    8010595c <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80105948:	e8 d6 eb ff ff       	call   80104523 <mycpu>
8010594d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105950:	81 e2 00 02 00 00    	and    $0x200,%edx
80105956:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
8010595c:	e8 c2 eb ff ff       	call   80104523 <mycpu>
80105961:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105967:	42                   	inc    %edx
80105968:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
8010596e:	c9                   	leave  
8010596f:	c3                   	ret    

80105970 <popcli>:

void
popcli(void)
{
80105970:	55                   	push   %ebp
80105971:	89 e5                	mov    %esp,%ebp
80105973:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80105976:	e8 f5 fd ff ff       	call   80105770 <readeflags>
8010597b:	25 00 02 00 00       	and    $0x200,%eax
80105980:	85 c0                	test   %eax,%eax
80105982:	74 0c                	je     80105990 <popcli+0x20>
    panic("popcli - interruptible");
80105984:	c7 04 24 97 a2 10 80 	movl   $0x8010a297,(%esp)
8010598b:	e8 c4 ab ff ff       	call   80100554 <panic>
  if(--mycpu()->ncli < 0)
80105990:	e8 8e eb ff ff       	call   80104523 <mycpu>
80105995:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
8010599b:	4a                   	dec    %edx
8010599c:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
801059a2:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801059a8:	85 c0                	test   %eax,%eax
801059aa:	79 0c                	jns    801059b8 <popcli+0x48>
    panic("popcli");
801059ac:	c7 04 24 ae a2 10 80 	movl   $0x8010a2ae,(%esp)
801059b3:	e8 9c ab ff ff       	call   80100554 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
801059b8:	e8 66 eb ff ff       	call   80104523 <mycpu>
801059bd:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801059c3:	85 c0                	test   %eax,%eax
801059c5:	75 14                	jne    801059db <popcli+0x6b>
801059c7:	e8 57 eb ff ff       	call   80104523 <mycpu>
801059cc:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801059d2:	85 c0                	test   %eax,%eax
801059d4:	74 05                	je     801059db <popcli+0x6b>
    sti();
801059d6:	e8 ab fd ff ff       	call   80105786 <sti>
}
801059db:	c9                   	leave  
801059dc:	c3                   	ret    
801059dd:	00 00                	add    %al,(%eax)
	...

801059e0 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801059e0:	55                   	push   %ebp
801059e1:	89 e5                	mov    %esp,%ebp
801059e3:	57                   	push   %edi
801059e4:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801059e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
801059e8:	8b 55 10             	mov    0x10(%ebp),%edx
801059eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801059ee:	89 cb                	mov    %ecx,%ebx
801059f0:	89 df                	mov    %ebx,%edi
801059f2:	89 d1                	mov    %edx,%ecx
801059f4:	fc                   	cld    
801059f5:	f3 aa                	rep stos %al,%es:(%edi)
801059f7:	89 ca                	mov    %ecx,%edx
801059f9:	89 fb                	mov    %edi,%ebx
801059fb:	89 5d 08             	mov    %ebx,0x8(%ebp)
801059fe:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105a01:	5b                   	pop    %ebx
80105a02:	5f                   	pop    %edi
80105a03:	5d                   	pop    %ebp
80105a04:	c3                   	ret    

80105a05 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105a05:	55                   	push   %ebp
80105a06:	89 e5                	mov    %esp,%ebp
80105a08:	57                   	push   %edi
80105a09:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105a0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105a0d:	8b 55 10             	mov    0x10(%ebp),%edx
80105a10:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a13:	89 cb                	mov    %ecx,%ebx
80105a15:	89 df                	mov    %ebx,%edi
80105a17:	89 d1                	mov    %edx,%ecx
80105a19:	fc                   	cld    
80105a1a:	f3 ab                	rep stos %eax,%es:(%edi)
80105a1c:	89 ca                	mov    %ecx,%edx
80105a1e:	89 fb                	mov    %edi,%ebx
80105a20:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105a23:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105a26:	5b                   	pop    %ebx
80105a27:	5f                   	pop    %edi
80105a28:	5d                   	pop    %ebp
80105a29:	c3                   	ret    

80105a2a <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105a2a:	55                   	push   %ebp
80105a2b:	89 e5                	mov    %esp,%ebp
80105a2d:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105a30:	8b 45 08             	mov    0x8(%ebp),%eax
80105a33:	83 e0 03             	and    $0x3,%eax
80105a36:	85 c0                	test   %eax,%eax
80105a38:	75 49                	jne    80105a83 <memset+0x59>
80105a3a:	8b 45 10             	mov    0x10(%ebp),%eax
80105a3d:	83 e0 03             	and    $0x3,%eax
80105a40:	85 c0                	test   %eax,%eax
80105a42:	75 3f                	jne    80105a83 <memset+0x59>
    c &= 0xFF;
80105a44:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105a4b:	8b 45 10             	mov    0x10(%ebp),%eax
80105a4e:	c1 e8 02             	shr    $0x2,%eax
80105a51:	89 c2                	mov    %eax,%edx
80105a53:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a56:	c1 e0 18             	shl    $0x18,%eax
80105a59:	89 c1                	mov    %eax,%ecx
80105a5b:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a5e:	c1 e0 10             	shl    $0x10,%eax
80105a61:	09 c1                	or     %eax,%ecx
80105a63:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a66:	c1 e0 08             	shl    $0x8,%eax
80105a69:	09 c8                	or     %ecx,%eax
80105a6b:	0b 45 0c             	or     0xc(%ebp),%eax
80105a6e:	89 54 24 08          	mov    %edx,0x8(%esp)
80105a72:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a76:	8b 45 08             	mov    0x8(%ebp),%eax
80105a79:	89 04 24             	mov    %eax,(%esp)
80105a7c:	e8 84 ff ff ff       	call   80105a05 <stosl>
80105a81:	eb 19                	jmp    80105a9c <memset+0x72>
  } else
    stosb(dst, c, n);
80105a83:	8b 45 10             	mov    0x10(%ebp),%eax
80105a86:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a8a:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a8d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a91:	8b 45 08             	mov    0x8(%ebp),%eax
80105a94:	89 04 24             	mov    %eax,(%esp)
80105a97:	e8 44 ff ff ff       	call   801059e0 <stosb>
  return dst;
80105a9c:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105a9f:	c9                   	leave  
80105aa0:	c3                   	ret    

80105aa1 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105aa1:	55                   	push   %ebp
80105aa2:	89 e5                	mov    %esp,%ebp
80105aa4:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80105aa7:	8b 45 08             	mov    0x8(%ebp),%eax
80105aaa:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105aad:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ab0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105ab3:	eb 2a                	jmp    80105adf <memcmp+0x3e>
    if(*s1 != *s2)
80105ab5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ab8:	8a 10                	mov    (%eax),%dl
80105aba:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105abd:	8a 00                	mov    (%eax),%al
80105abf:	38 c2                	cmp    %al,%dl
80105ac1:	74 16                	je     80105ad9 <memcmp+0x38>
      return *s1 - *s2;
80105ac3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ac6:	8a 00                	mov    (%eax),%al
80105ac8:	0f b6 d0             	movzbl %al,%edx
80105acb:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105ace:	8a 00                	mov    (%eax),%al
80105ad0:	0f b6 c0             	movzbl %al,%eax
80105ad3:	29 c2                	sub    %eax,%edx
80105ad5:	89 d0                	mov    %edx,%eax
80105ad7:	eb 18                	jmp    80105af1 <memcmp+0x50>
    s1++, s2++;
80105ad9:	ff 45 fc             	incl   -0x4(%ebp)
80105adc:	ff 45 f8             	incl   -0x8(%ebp)
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105adf:	8b 45 10             	mov    0x10(%ebp),%eax
80105ae2:	8d 50 ff             	lea    -0x1(%eax),%edx
80105ae5:	89 55 10             	mov    %edx,0x10(%ebp)
80105ae8:	85 c0                	test   %eax,%eax
80105aea:	75 c9                	jne    80105ab5 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105aec:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105af1:	c9                   	leave  
80105af2:	c3                   	ret    

80105af3 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105af3:	55                   	push   %ebp
80105af4:	89 e5                	mov    %esp,%ebp
80105af6:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105af9:	8b 45 0c             	mov    0xc(%ebp),%eax
80105afc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105aff:	8b 45 08             	mov    0x8(%ebp),%eax
80105b02:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105b05:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105b08:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105b0b:	73 3a                	jae    80105b47 <memmove+0x54>
80105b0d:	8b 45 10             	mov    0x10(%ebp),%eax
80105b10:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105b13:	01 d0                	add    %edx,%eax
80105b15:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105b18:	76 2d                	jbe    80105b47 <memmove+0x54>
    s += n;
80105b1a:	8b 45 10             	mov    0x10(%ebp),%eax
80105b1d:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105b20:	8b 45 10             	mov    0x10(%ebp),%eax
80105b23:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105b26:	eb 10                	jmp    80105b38 <memmove+0x45>
      *--d = *--s;
80105b28:	ff 4d f8             	decl   -0x8(%ebp)
80105b2b:	ff 4d fc             	decl   -0x4(%ebp)
80105b2e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105b31:	8a 10                	mov    (%eax),%dl
80105b33:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105b36:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105b38:	8b 45 10             	mov    0x10(%ebp),%eax
80105b3b:	8d 50 ff             	lea    -0x1(%eax),%edx
80105b3e:	89 55 10             	mov    %edx,0x10(%ebp)
80105b41:	85 c0                	test   %eax,%eax
80105b43:	75 e3                	jne    80105b28 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105b45:	eb 25                	jmp    80105b6c <memmove+0x79>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105b47:	eb 16                	jmp    80105b5f <memmove+0x6c>
      *d++ = *s++;
80105b49:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105b4c:	8d 50 01             	lea    0x1(%eax),%edx
80105b4f:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105b52:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105b55:	8d 4a 01             	lea    0x1(%edx),%ecx
80105b58:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105b5b:	8a 12                	mov    (%edx),%dl
80105b5d:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105b5f:	8b 45 10             	mov    0x10(%ebp),%eax
80105b62:	8d 50 ff             	lea    -0x1(%eax),%edx
80105b65:	89 55 10             	mov    %edx,0x10(%ebp)
80105b68:	85 c0                	test   %eax,%eax
80105b6a:	75 dd                	jne    80105b49 <memmove+0x56>
      *d++ = *s++;

  return dst;
80105b6c:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105b6f:	c9                   	leave  
80105b70:	c3                   	ret    

80105b71 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105b71:	55                   	push   %ebp
80105b72:	89 e5                	mov    %esp,%ebp
80105b74:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80105b77:	8b 45 10             	mov    0x10(%ebp),%eax
80105b7a:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b7e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b81:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b85:	8b 45 08             	mov    0x8(%ebp),%eax
80105b88:	89 04 24             	mov    %eax,(%esp)
80105b8b:	e8 63 ff ff ff       	call   80105af3 <memmove>
}
80105b90:	c9                   	leave  
80105b91:	c3                   	ret    

80105b92 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105b92:	55                   	push   %ebp
80105b93:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105b95:	eb 09                	jmp    80105ba0 <strncmp+0xe>
    n--, p++, q++;
80105b97:	ff 4d 10             	decl   0x10(%ebp)
80105b9a:	ff 45 08             	incl   0x8(%ebp)
80105b9d:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105ba0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105ba4:	74 17                	je     80105bbd <strncmp+0x2b>
80105ba6:	8b 45 08             	mov    0x8(%ebp),%eax
80105ba9:	8a 00                	mov    (%eax),%al
80105bab:	84 c0                	test   %al,%al
80105bad:	74 0e                	je     80105bbd <strncmp+0x2b>
80105baf:	8b 45 08             	mov    0x8(%ebp),%eax
80105bb2:	8a 10                	mov    (%eax),%dl
80105bb4:	8b 45 0c             	mov    0xc(%ebp),%eax
80105bb7:	8a 00                	mov    (%eax),%al
80105bb9:	38 c2                	cmp    %al,%dl
80105bbb:	74 da                	je     80105b97 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105bbd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105bc1:	75 07                	jne    80105bca <strncmp+0x38>
    return 0;
80105bc3:	b8 00 00 00 00       	mov    $0x0,%eax
80105bc8:	eb 14                	jmp    80105bde <strncmp+0x4c>
  return (uchar)*p - (uchar)*q;
80105bca:	8b 45 08             	mov    0x8(%ebp),%eax
80105bcd:	8a 00                	mov    (%eax),%al
80105bcf:	0f b6 d0             	movzbl %al,%edx
80105bd2:	8b 45 0c             	mov    0xc(%ebp),%eax
80105bd5:	8a 00                	mov    (%eax),%al
80105bd7:	0f b6 c0             	movzbl %al,%eax
80105bda:	29 c2                	sub    %eax,%edx
80105bdc:	89 d0                	mov    %edx,%eax
}
80105bde:	5d                   	pop    %ebp
80105bdf:	c3                   	ret    

80105be0 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105be0:	55                   	push   %ebp
80105be1:	89 e5                	mov    %esp,%ebp
80105be3:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105be6:	8b 45 08             	mov    0x8(%ebp),%eax
80105be9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105bec:	90                   	nop
80105bed:	8b 45 10             	mov    0x10(%ebp),%eax
80105bf0:	8d 50 ff             	lea    -0x1(%eax),%edx
80105bf3:	89 55 10             	mov    %edx,0x10(%ebp)
80105bf6:	85 c0                	test   %eax,%eax
80105bf8:	7e 1c                	jle    80105c16 <strncpy+0x36>
80105bfa:	8b 45 08             	mov    0x8(%ebp),%eax
80105bfd:	8d 50 01             	lea    0x1(%eax),%edx
80105c00:	89 55 08             	mov    %edx,0x8(%ebp)
80105c03:	8b 55 0c             	mov    0xc(%ebp),%edx
80105c06:	8d 4a 01             	lea    0x1(%edx),%ecx
80105c09:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105c0c:	8a 12                	mov    (%edx),%dl
80105c0e:	88 10                	mov    %dl,(%eax)
80105c10:	8a 00                	mov    (%eax),%al
80105c12:	84 c0                	test   %al,%al
80105c14:	75 d7                	jne    80105bed <strncpy+0xd>
    ;
  while(n-- > 0)
80105c16:	eb 0c                	jmp    80105c24 <strncpy+0x44>
    *s++ = 0;
80105c18:	8b 45 08             	mov    0x8(%ebp),%eax
80105c1b:	8d 50 01             	lea    0x1(%eax),%edx
80105c1e:	89 55 08             	mov    %edx,0x8(%ebp)
80105c21:	c6 00 00             	movb   $0x0,(%eax)
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105c24:	8b 45 10             	mov    0x10(%ebp),%eax
80105c27:	8d 50 ff             	lea    -0x1(%eax),%edx
80105c2a:	89 55 10             	mov    %edx,0x10(%ebp)
80105c2d:	85 c0                	test   %eax,%eax
80105c2f:	7f e7                	jg     80105c18 <strncpy+0x38>
    *s++ = 0;
  return os;
80105c31:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105c34:	c9                   	leave  
80105c35:	c3                   	ret    

80105c36 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105c36:	55                   	push   %ebp
80105c37:	89 e5                	mov    %esp,%ebp
80105c39:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105c3c:	8b 45 08             	mov    0x8(%ebp),%eax
80105c3f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105c42:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105c46:	7f 05                	jg     80105c4d <safestrcpy+0x17>
    return os;
80105c48:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c4b:	eb 2e                	jmp    80105c7b <safestrcpy+0x45>
  while(--n > 0 && (*s++ = *t++) != 0)
80105c4d:	ff 4d 10             	decl   0x10(%ebp)
80105c50:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105c54:	7e 1c                	jle    80105c72 <safestrcpy+0x3c>
80105c56:	8b 45 08             	mov    0x8(%ebp),%eax
80105c59:	8d 50 01             	lea    0x1(%eax),%edx
80105c5c:	89 55 08             	mov    %edx,0x8(%ebp)
80105c5f:	8b 55 0c             	mov    0xc(%ebp),%edx
80105c62:	8d 4a 01             	lea    0x1(%edx),%ecx
80105c65:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105c68:	8a 12                	mov    (%edx),%dl
80105c6a:	88 10                	mov    %dl,(%eax)
80105c6c:	8a 00                	mov    (%eax),%al
80105c6e:	84 c0                	test   %al,%al
80105c70:	75 db                	jne    80105c4d <safestrcpy+0x17>
    ;
  *s = 0;
80105c72:	8b 45 08             	mov    0x8(%ebp),%eax
80105c75:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105c78:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105c7b:	c9                   	leave  
80105c7c:	c3                   	ret    

80105c7d <strlen>:

int
strlen(const char *s)
{
80105c7d:	55                   	push   %ebp
80105c7e:	89 e5                	mov    %esp,%ebp
80105c80:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105c83:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105c8a:	eb 03                	jmp    80105c8f <strlen+0x12>
80105c8c:	ff 45 fc             	incl   -0x4(%ebp)
80105c8f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105c92:	8b 45 08             	mov    0x8(%ebp),%eax
80105c95:	01 d0                	add    %edx,%eax
80105c97:	8a 00                	mov    (%eax),%al
80105c99:	84 c0                	test   %al,%al
80105c9b:	75 ef                	jne    80105c8c <strlen+0xf>
    ;
  return n;
80105c9d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105ca0:	c9                   	leave  
80105ca1:	c3                   	ret    
	...

80105ca4 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105ca4:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105ca8:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105cac:	55                   	push   %ebp
  pushl %ebx
80105cad:	53                   	push   %ebx
  pushl %esi
80105cae:	56                   	push   %esi
  pushl %edi
80105caf:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105cb0:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105cb2:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105cb4:	5f                   	pop    %edi
  popl %esi
80105cb5:	5e                   	pop    %esi
  popl %ebx
80105cb6:	5b                   	pop    %ebx
  popl %ebp
80105cb7:	5d                   	pop    %ebp
  ret
80105cb8:	c3                   	ret    
80105cb9:	00 00                	add    %al,(%eax)
	...

80105cbc <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105cbc:	55                   	push   %ebp
80105cbd:	89 e5                	mov    %esp,%ebp
80105cbf:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80105cc2:	e8 e0 e8 ff ff       	call   801045a7 <myproc>
80105cc7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105cca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ccd:	8b 00                	mov    (%eax),%eax
80105ccf:	3b 45 08             	cmp    0x8(%ebp),%eax
80105cd2:	76 0f                	jbe    80105ce3 <fetchint+0x27>
80105cd4:	8b 45 08             	mov    0x8(%ebp),%eax
80105cd7:	8d 50 04             	lea    0x4(%eax),%edx
80105cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cdd:	8b 00                	mov    (%eax),%eax
80105cdf:	39 c2                	cmp    %eax,%edx
80105ce1:	76 07                	jbe    80105cea <fetchint+0x2e>
    return -1;
80105ce3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ce8:	eb 0f                	jmp    80105cf9 <fetchint+0x3d>
  *ip = *(int*)(addr);
80105cea:	8b 45 08             	mov    0x8(%ebp),%eax
80105ced:	8b 10                	mov    (%eax),%edx
80105cef:	8b 45 0c             	mov    0xc(%ebp),%eax
80105cf2:	89 10                	mov    %edx,(%eax)
  return 0;
80105cf4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cf9:	c9                   	leave  
80105cfa:	c3                   	ret    

80105cfb <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105cfb:	55                   	push   %ebp
80105cfc:	89 e5                	mov    %esp,%ebp
80105cfe:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105d01:	e8 a1 e8 ff ff       	call   801045a7 <myproc>
80105d06:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105d09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d0c:	8b 00                	mov    (%eax),%eax
80105d0e:	3b 45 08             	cmp    0x8(%ebp),%eax
80105d11:	77 07                	ja     80105d1a <fetchstr+0x1f>
    return -1;
80105d13:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d18:	eb 41                	jmp    80105d5b <fetchstr+0x60>
  *pp = (char*)addr;
80105d1a:	8b 55 08             	mov    0x8(%ebp),%edx
80105d1d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d20:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105d22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d25:	8b 00                	mov    (%eax),%eax
80105d27:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105d2a:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d2d:	8b 00                	mov    (%eax),%eax
80105d2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d32:	eb 1a                	jmp    80105d4e <fetchstr+0x53>
    if(*s == 0)
80105d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d37:	8a 00                	mov    (%eax),%al
80105d39:	84 c0                	test   %al,%al
80105d3b:	75 0e                	jne    80105d4b <fetchstr+0x50>
      return s - *pp;
80105d3d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d40:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d43:	8b 00                	mov    (%eax),%eax
80105d45:	29 c2                	sub    %eax,%edx
80105d47:	89 d0                	mov    %edx,%eax
80105d49:	eb 10                	jmp    80105d5b <fetchstr+0x60>

  if(addr >= curproc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
80105d4b:	ff 45 f4             	incl   -0xc(%ebp)
80105d4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d51:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105d54:	72 de                	jb     80105d34 <fetchstr+0x39>
    if(*s == 0)
      return s - *pp;
  }
  return -1;
80105d56:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d5b:	c9                   	leave  
80105d5c:	c3                   	ret    

80105d5d <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105d5d:	55                   	push   %ebp
80105d5e:	89 e5                	mov    %esp,%ebp
80105d60:	83 ec 18             	sub    $0x18,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105d63:	e8 3f e8 ff ff       	call   801045a7 <myproc>
80105d68:	8b 40 18             	mov    0x18(%eax),%eax
80105d6b:	8b 50 44             	mov    0x44(%eax),%edx
80105d6e:	8b 45 08             	mov    0x8(%ebp),%eax
80105d71:	c1 e0 02             	shl    $0x2,%eax
80105d74:	01 d0                	add    %edx,%eax
80105d76:	8d 50 04             	lea    0x4(%eax),%edx
80105d79:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d7c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d80:	89 14 24             	mov    %edx,(%esp)
80105d83:	e8 34 ff ff ff       	call   80105cbc <fetchint>
}
80105d88:	c9                   	leave  
80105d89:	c3                   	ret    

80105d8a <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105d8a:	55                   	push   %ebp
80105d8b:	89 e5                	mov    %esp,%ebp
80105d8d:	83 ec 28             	sub    $0x28,%esp
  int i;
  struct proc *curproc = myproc();
80105d90:	e8 12 e8 ff ff       	call   801045a7 <myproc>
80105d95:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105d98:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d9b:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d9f:	8b 45 08             	mov    0x8(%ebp),%eax
80105da2:	89 04 24             	mov    %eax,(%esp)
80105da5:	e8 b3 ff ff ff       	call   80105d5d <argint>
80105daa:	85 c0                	test   %eax,%eax
80105dac:	79 07                	jns    80105db5 <argptr+0x2b>
    return -1;
80105dae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105db3:	eb 3d                	jmp    80105df2 <argptr+0x68>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105db5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105db9:	78 21                	js     80105ddc <argptr+0x52>
80105dbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dbe:	89 c2                	mov    %eax,%edx
80105dc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dc3:	8b 00                	mov    (%eax),%eax
80105dc5:	39 c2                	cmp    %eax,%edx
80105dc7:	73 13                	jae    80105ddc <argptr+0x52>
80105dc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dcc:	89 c2                	mov    %eax,%edx
80105dce:	8b 45 10             	mov    0x10(%ebp),%eax
80105dd1:	01 c2                	add    %eax,%edx
80105dd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dd6:	8b 00                	mov    (%eax),%eax
80105dd8:	39 c2                	cmp    %eax,%edx
80105dda:	76 07                	jbe    80105de3 <argptr+0x59>
    return -1;
80105ddc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105de1:	eb 0f                	jmp    80105df2 <argptr+0x68>
  *pp = (char*)i;
80105de3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105de6:	89 c2                	mov    %eax,%edx
80105de8:	8b 45 0c             	mov    0xc(%ebp),%eax
80105deb:	89 10                	mov    %edx,(%eax)
  return 0;
80105ded:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105df2:	c9                   	leave  
80105df3:	c3                   	ret    

80105df4 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105df4:	55                   	push   %ebp
80105df5:	89 e5                	mov    %esp,%ebp
80105df7:	83 ec 28             	sub    $0x28,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105dfa:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105dfd:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e01:	8b 45 08             	mov    0x8(%ebp),%eax
80105e04:	89 04 24             	mov    %eax,(%esp)
80105e07:	e8 51 ff ff ff       	call   80105d5d <argint>
80105e0c:	85 c0                	test   %eax,%eax
80105e0e:	79 07                	jns    80105e17 <argstr+0x23>
    return -1;
80105e10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e15:	eb 12                	jmp    80105e29 <argstr+0x35>
  return fetchstr(addr, pp);
80105e17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e1a:	8b 55 0c             	mov    0xc(%ebp),%edx
80105e1d:	89 54 24 04          	mov    %edx,0x4(%esp)
80105e21:	89 04 24             	mov    %eax,(%esp)
80105e24:	e8 d2 fe ff ff       	call   80105cfb <fetchstr>
}
80105e29:	c9                   	leave  
80105e2a:	c3                   	ret    

80105e2b <syscall>:
[SYS_tick_reset2] sys_tick_reset2,
};

void
syscall(void)
{
80105e2b:	55                   	push   %ebp
80105e2c:	89 e5                	mov    %esp,%ebp
80105e2e:	53                   	push   %ebx
80105e2f:	83 ec 24             	sub    $0x24,%esp
  int num;
  struct proc *curproc = myproc();
80105e32:	e8 70 e7 ff ff       	call   801045a7 <myproc>
80105e37:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e3d:	8b 40 18             	mov    0x18(%eax),%eax
80105e40:	8b 40 1c             	mov    0x1c(%eax),%eax
80105e43:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105e46:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e4a:	7e 2d                	jle    80105e79 <syscall+0x4e>
80105e4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e4f:	83 f8 39             	cmp    $0x39,%eax
80105e52:	77 25                	ja     80105e79 <syscall+0x4e>
80105e54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e57:	8b 04 85 60 d0 10 80 	mov    -0x7fef2fa0(,%eax,4),%eax
80105e5e:	85 c0                	test   %eax,%eax
80105e60:	74 17                	je     80105e79 <syscall+0x4e>
    curproc->tf->eax = syscalls[num]();
80105e62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e65:	8b 58 18             	mov    0x18(%eax),%ebx
80105e68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e6b:	8b 04 85 60 d0 10 80 	mov    -0x7fef2fa0(,%eax,4),%eax
80105e72:	ff d0                	call   *%eax
80105e74:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105e77:	eb 34                	jmp    80105ead <syscall+0x82>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e7c:	8d 48 6c             	lea    0x6c(%eax),%ecx

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105e7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e82:	8b 40 10             	mov    0x10(%eax),%eax
80105e85:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105e88:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105e8c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105e90:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e94:	c7 04 24 b5 a2 10 80 	movl   $0x8010a2b5,(%esp)
80105e9b:	e8 21 a5 ff ff       	call   801003c1 <cprintf>
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
80105ea0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ea3:	8b 40 18             	mov    0x18(%eax),%eax
80105ea6:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105ead:	83 c4 24             	add    $0x24,%esp
80105eb0:	5b                   	pop    %ebx
80105eb1:	5d                   	pop    %ebp
80105eb2:	c3                   	ret    
	...

80105eb4 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105eb4:	55                   	push   %ebp
80105eb5:	89 e5                	mov    %esp,%ebp
80105eb7:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105eba:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ebd:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ec1:	8b 45 08             	mov    0x8(%ebp),%eax
80105ec4:	89 04 24             	mov    %eax,(%esp)
80105ec7:	e8 91 fe ff ff       	call   80105d5d <argint>
80105ecc:	85 c0                	test   %eax,%eax
80105ece:	79 07                	jns    80105ed7 <argfd+0x23>
    return -1;
80105ed0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ed5:	eb 4f                	jmp    80105f26 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105ed7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eda:	85 c0                	test   %eax,%eax
80105edc:	78 20                	js     80105efe <argfd+0x4a>
80105ede:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ee1:	83 f8 0f             	cmp    $0xf,%eax
80105ee4:	7f 18                	jg     80105efe <argfd+0x4a>
80105ee6:	e8 bc e6 ff ff       	call   801045a7 <myproc>
80105eeb:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105eee:	83 c2 08             	add    $0x8,%edx
80105ef1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105ef5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ef8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105efc:	75 07                	jne    80105f05 <argfd+0x51>
    return -1;
80105efe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f03:	eb 21                	jmp    80105f26 <argfd+0x72>
  if(pfd)
80105f05:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105f09:	74 08                	je     80105f13 <argfd+0x5f>
    *pfd = fd;
80105f0b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105f0e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f11:	89 10                	mov    %edx,(%eax)
  if(pf)
80105f13:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105f17:	74 08                	je     80105f21 <argfd+0x6d>
    *pf = f;
80105f19:	8b 45 10             	mov    0x10(%ebp),%eax
80105f1c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f1f:	89 10                	mov    %edx,(%eax)
  return 0;
80105f21:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f26:	c9                   	leave  
80105f27:	c3                   	ret    

80105f28 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105f28:	55                   	push   %ebp
80105f29:	89 e5                	mov    %esp,%ebp
80105f2b:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105f2e:	e8 74 e6 ff ff       	call   801045a7 <myproc>
80105f33:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105f36:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105f3d:	eb 29                	jmp    80105f68 <fdalloc+0x40>
    if(curproc->ofile[fd] == 0){
80105f3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f42:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f45:	83 c2 08             	add    $0x8,%edx
80105f48:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105f4c:	85 c0                	test   %eax,%eax
80105f4e:	75 15                	jne    80105f65 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105f50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f53:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f56:	8d 4a 08             	lea    0x8(%edx),%ecx
80105f59:	8b 55 08             	mov    0x8(%ebp),%edx
80105f5c:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105f60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f63:	eb 0e                	jmp    80105f73 <fdalloc+0x4b>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
80105f65:	ff 45 f4             	incl   -0xc(%ebp)
80105f68:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105f6c:	7e d1                	jle    80105f3f <fdalloc+0x17>
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105f6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105f73:	c9                   	leave  
80105f74:	c3                   	ret    

80105f75 <sys_dup>:

int
sys_dup(void)
{
80105f75:	55                   	push   %ebp
80105f76:	89 e5                	mov    %esp,%ebp
80105f78:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105f7b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f7e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f82:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105f89:	00 
80105f8a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f91:	e8 1e ff ff ff       	call   80105eb4 <argfd>
80105f96:	85 c0                	test   %eax,%eax
80105f98:	79 07                	jns    80105fa1 <sys_dup+0x2c>
    return -1;
80105f9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f9f:	eb 29                	jmp    80105fca <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105fa1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fa4:	89 04 24             	mov    %eax,(%esp)
80105fa7:	e8 7c ff ff ff       	call   80105f28 <fdalloc>
80105fac:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105faf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fb3:	79 07                	jns    80105fbc <sys_dup+0x47>
    return -1;
80105fb5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fba:	eb 0e                	jmp    80105fca <sys_dup+0x55>
  filedup(f);
80105fbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fbf:	89 04 24             	mov    %eax,(%esp)
80105fc2:	e8 9b b1 ff ff       	call   80101162 <filedup>
  return fd;
80105fc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105fca:	c9                   	leave  
80105fcb:	c3                   	ret    

80105fcc <sys_read>:

int
sys_read(void)
{
80105fcc:	55                   	push   %ebp
80105fcd:	89 e5                	mov    %esp,%ebp
80105fcf:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105fd2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105fd5:	89 44 24 08          	mov    %eax,0x8(%esp)
80105fd9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105fe0:	00 
80105fe1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105fe8:	e8 c7 fe ff ff       	call   80105eb4 <argfd>
80105fed:	85 c0                	test   %eax,%eax
80105fef:	78 35                	js     80106026 <sys_read+0x5a>
80105ff1:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ff4:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ff8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105fff:	e8 59 fd ff ff       	call   80105d5d <argint>
80106004:	85 c0                	test   %eax,%eax
80106006:	78 1e                	js     80106026 <sys_read+0x5a>
80106008:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010600b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010600f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106012:	89 44 24 04          	mov    %eax,0x4(%esp)
80106016:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010601d:	e8 68 fd ff ff       	call   80105d8a <argptr>
80106022:	85 c0                	test   %eax,%eax
80106024:	79 07                	jns    8010602d <sys_read+0x61>
    return -1;
80106026:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010602b:	eb 19                	jmp    80106046 <sys_read+0x7a>
  return fileread(f, p, n);
8010602d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106030:	8b 55 ec             	mov    -0x14(%ebp),%edx
80106033:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106036:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010603a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010603e:	89 04 24             	mov    %eax,(%esp)
80106041:	e8 7d b2 ff ff       	call   801012c3 <fileread>
}
80106046:	c9                   	leave  
80106047:	c3                   	ret    

80106048 <sys_write>:

int
sys_write(void)
{
80106048:	55                   	push   %ebp
80106049:	89 e5                	mov    %esp,%ebp
8010604b:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010604e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106051:	89 44 24 08          	mov    %eax,0x8(%esp)
80106055:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010605c:	00 
8010605d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106064:	e8 4b fe ff ff       	call   80105eb4 <argfd>
80106069:	85 c0                	test   %eax,%eax
8010606b:	78 35                	js     801060a2 <sys_write+0x5a>
8010606d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106070:	89 44 24 04          	mov    %eax,0x4(%esp)
80106074:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010607b:	e8 dd fc ff ff       	call   80105d5d <argint>
80106080:	85 c0                	test   %eax,%eax
80106082:	78 1e                	js     801060a2 <sys_write+0x5a>
80106084:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106087:	89 44 24 08          	mov    %eax,0x8(%esp)
8010608b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010608e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106092:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106099:	e8 ec fc ff ff       	call   80105d8a <argptr>
8010609e:	85 c0                	test   %eax,%eax
801060a0:	79 07                	jns    801060a9 <sys_write+0x61>
    return -1;
801060a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060a7:	eb 19                	jmp    801060c2 <sys_write+0x7a>
  return filewrite(f, p, n);
801060a9:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801060ac:	8b 55 ec             	mov    -0x14(%ebp),%edx
801060af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060b2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801060b6:	89 54 24 04          	mov    %edx,0x4(%esp)
801060ba:	89 04 24             	mov    %eax,(%esp)
801060bd:	e8 bc b2 ff ff       	call   8010137e <filewrite>
}
801060c2:	c9                   	leave  
801060c3:	c3                   	ret    

801060c4 <sys_close>:

int
sys_close(void)
{
801060c4:	55                   	push   %ebp
801060c5:	89 e5                	mov    %esp,%ebp
801060c7:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801060ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060cd:	89 44 24 08          	mov    %eax,0x8(%esp)
801060d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801060d4:	89 44 24 04          	mov    %eax,0x4(%esp)
801060d8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801060df:	e8 d0 fd ff ff       	call   80105eb4 <argfd>
801060e4:	85 c0                	test   %eax,%eax
801060e6:	79 07                	jns    801060ef <sys_close+0x2b>
    return -1;
801060e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060ed:	eb 23                	jmp    80106112 <sys_close+0x4e>
  myproc()->ofile[fd] = 0;
801060ef:	e8 b3 e4 ff ff       	call   801045a7 <myproc>
801060f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060f7:	83 c2 08             	add    $0x8,%edx
801060fa:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106101:	00 
  fileclose(f);
80106102:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106105:	89 04 24             	mov    %eax,(%esp)
80106108:	e8 9d b0 ff ff       	call   801011aa <fileclose>
  return 0;
8010610d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106112:	c9                   	leave  
80106113:	c3                   	ret    

80106114 <sys_fstat>:

int
sys_fstat(void)
{
80106114:	55                   	push   %ebp
80106115:	89 e5                	mov    %esp,%ebp
80106117:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010611a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010611d:	89 44 24 08          	mov    %eax,0x8(%esp)
80106121:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106128:	00 
80106129:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106130:	e8 7f fd ff ff       	call   80105eb4 <argfd>
80106135:	85 c0                	test   %eax,%eax
80106137:	78 1f                	js     80106158 <sys_fstat+0x44>
80106139:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80106140:	00 
80106141:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106144:	89 44 24 04          	mov    %eax,0x4(%esp)
80106148:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010614f:	e8 36 fc ff ff       	call   80105d8a <argptr>
80106154:	85 c0                	test   %eax,%eax
80106156:	79 07                	jns    8010615f <sys_fstat+0x4b>
    return -1;
80106158:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010615d:	eb 12                	jmp    80106171 <sys_fstat+0x5d>
  return filestat(f, st);
8010615f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106165:	89 54 24 04          	mov    %edx,0x4(%esp)
80106169:	89 04 24             	mov    %eax,(%esp)
8010616c:	e8 03 b1 ff ff       	call   80101274 <filestat>
}
80106171:	c9                   	leave  
80106172:	c3                   	ret    

80106173 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80106173:	55                   	push   %ebp
80106174:	89 e5                	mov    %esp,%ebp
80106176:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80106179:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010617c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106180:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106187:	e8 68 fc ff ff       	call   80105df4 <argstr>
8010618c:	85 c0                	test   %eax,%eax
8010618e:	78 17                	js     801061a7 <sys_link+0x34>
80106190:	8d 45 dc             	lea    -0x24(%ebp),%eax
80106193:	89 44 24 04          	mov    %eax,0x4(%esp)
80106197:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010619e:	e8 51 fc ff ff       	call   80105df4 <argstr>
801061a3:	85 c0                	test   %eax,%eax
801061a5:	79 0a                	jns    801061b1 <sys_link+0x3e>
    return -1;
801061a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061ac:	e9 3d 01 00 00       	jmp    801062ee <sys_link+0x17b>

  begin_op();
801061b1:	e8 f1 d6 ff ff       	call   801038a7 <begin_op>
  if((ip = namei(old)) == 0){
801061b6:	8b 45 d8             	mov    -0x28(%ebp),%eax
801061b9:	89 04 24             	mov    %eax,(%esp)
801061bc:	e8 e1 c5 ff ff       	call   801027a2 <namei>
801061c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061c4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061c8:	75 0f                	jne    801061d9 <sys_link+0x66>
    end_op();
801061ca:	e8 5a d7 ff ff       	call   80103929 <end_op>
    return -1;
801061cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061d4:	e9 15 01 00 00       	jmp    801062ee <sys_link+0x17b>
  }

  ilock(ip);
801061d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061dc:	89 04 24             	mov    %eax,(%esp)
801061df:	e8 43 b9 ff ff       	call   80101b27 <ilock>
  if(ip->type == T_DIR){
801061e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061e7:	8b 40 50             	mov    0x50(%eax),%eax
801061ea:	66 83 f8 01          	cmp    $0x1,%ax
801061ee:	75 1a                	jne    8010620a <sys_link+0x97>
    iunlockput(ip);
801061f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061f3:	89 04 24             	mov    %eax,(%esp)
801061f6:	e8 2b bb ff ff       	call   80101d26 <iunlockput>
    end_op();
801061fb:	e8 29 d7 ff ff       	call   80103929 <end_op>
    return -1;
80106200:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106205:	e9 e4 00 00 00       	jmp    801062ee <sys_link+0x17b>
  }

  ip->nlink++;
8010620a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010620d:	66 8b 40 56          	mov    0x56(%eax),%ax
80106211:	40                   	inc    %eax
80106212:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106215:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80106219:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010621c:	89 04 24             	mov    %eax,(%esp)
8010621f:	e8 40 b7 ff ff       	call   80101964 <iupdate>
  iunlock(ip);
80106224:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106227:	89 04 24             	mov    %eax,(%esp)
8010622a:	e8 02 ba ff ff       	call   80101c31 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
8010622f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106232:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80106235:	89 54 24 04          	mov    %edx,0x4(%esp)
80106239:	89 04 24             	mov    %eax,(%esp)
8010623c:	e8 83 c5 ff ff       	call   801027c4 <nameiparent>
80106241:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106244:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106248:	75 02                	jne    8010624c <sys_link+0xd9>
    goto bad;
8010624a:	eb 68                	jmp    801062b4 <sys_link+0x141>
  ilock(dp);
8010624c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010624f:	89 04 24             	mov    %eax,(%esp)
80106252:	e8 d0 b8 ff ff       	call   80101b27 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80106257:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010625a:	8b 10                	mov    (%eax),%edx
8010625c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010625f:	8b 00                	mov    (%eax),%eax
80106261:	39 c2                	cmp    %eax,%edx
80106263:	75 20                	jne    80106285 <sys_link+0x112>
80106265:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106268:	8b 40 04             	mov    0x4(%eax),%eax
8010626b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010626f:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106272:	89 44 24 04          	mov    %eax,0x4(%esp)
80106276:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106279:	89 04 24             	mov    %eax,(%esp)
8010627c:	e8 9e c1 ff ff       	call   8010241f <dirlink>
80106281:	85 c0                	test   %eax,%eax
80106283:	79 0d                	jns    80106292 <sys_link+0x11f>
    iunlockput(dp);
80106285:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106288:	89 04 24             	mov    %eax,(%esp)
8010628b:	e8 96 ba ff ff       	call   80101d26 <iunlockput>
    goto bad;
80106290:	eb 22                	jmp    801062b4 <sys_link+0x141>
  }
  iunlockput(dp);
80106292:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106295:	89 04 24             	mov    %eax,(%esp)
80106298:	e8 89 ba ff ff       	call   80101d26 <iunlockput>
  iput(ip);
8010629d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062a0:	89 04 24             	mov    %eax,(%esp)
801062a3:	e8 cd b9 ff ff       	call   80101c75 <iput>

  end_op();
801062a8:	e8 7c d6 ff ff       	call   80103929 <end_op>

  return 0;
801062ad:	b8 00 00 00 00       	mov    $0x0,%eax
801062b2:	eb 3a                	jmp    801062ee <sys_link+0x17b>

bad:
  ilock(ip);
801062b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062b7:	89 04 24             	mov    %eax,(%esp)
801062ba:	e8 68 b8 ff ff       	call   80101b27 <ilock>
  ip->nlink--;
801062bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062c2:	66 8b 40 56          	mov    0x56(%eax),%ax
801062c6:	48                   	dec    %eax
801062c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062ca:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
801062ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062d1:	89 04 24             	mov    %eax,(%esp)
801062d4:	e8 8b b6 ff ff       	call   80101964 <iupdate>
  iunlockput(ip);
801062d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062dc:	89 04 24             	mov    %eax,(%esp)
801062df:	e8 42 ba ff ff       	call   80101d26 <iunlockput>
  end_op();
801062e4:	e8 40 d6 ff ff       	call   80103929 <end_op>
  return -1;
801062e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801062ee:	c9                   	leave  
801062ef:	c3                   	ret    

801062f0 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801062f0:	55                   	push   %ebp
801062f1:	89 e5                	mov    %esp,%ebp
801062f3:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801062f6:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801062fd:	eb 4a                	jmp    80106349 <isdirempty+0x59>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801062ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106302:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80106309:	00 
8010630a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010630e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106311:	89 44 24 04          	mov    %eax,0x4(%esp)
80106315:	8b 45 08             	mov    0x8(%ebp),%eax
80106318:	89 04 24             	mov    %eax,(%esp)
8010631b:	e8 9e bc ff ff       	call   80101fbe <readi>
80106320:	83 f8 10             	cmp    $0x10,%eax
80106323:	74 0c                	je     80106331 <isdirempty+0x41>
      panic("isdirempty: readi");
80106325:	c7 04 24 d1 a2 10 80 	movl   $0x8010a2d1,(%esp)
8010632c:	e8 23 a2 ff ff       	call   80100554 <panic>
    if(de.inum != 0)
80106331:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106334:	66 85 c0             	test   %ax,%ax
80106337:	74 07                	je     80106340 <isdirempty+0x50>
      return 0;
80106339:	b8 00 00 00 00       	mov    $0x0,%eax
8010633e:	eb 1b                	jmp    8010635b <isdirempty+0x6b>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80106340:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106343:	83 c0 10             	add    $0x10,%eax
80106346:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106349:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010634c:	8b 45 08             	mov    0x8(%ebp),%eax
8010634f:	8b 40 58             	mov    0x58(%eax),%eax
80106352:	39 c2                	cmp    %eax,%edx
80106354:	72 a9                	jb     801062ff <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80106356:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010635b:	c9                   	leave  
8010635c:	c3                   	ret    

8010635d <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
8010635d:	55                   	push   %ebp
8010635e:	89 e5                	mov    %esp,%ebp
80106360:	83 ec 58             	sub    $0x58,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80106363:	8d 45 c0             	lea    -0x40(%ebp),%eax
80106366:	89 44 24 04          	mov    %eax,0x4(%esp)
8010636a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106371:	e8 7e fa ff ff       	call   80105df4 <argstr>
80106376:	85 c0                	test   %eax,%eax
80106378:	79 0a                	jns    80106384 <sys_unlink+0x27>
    return -1;
8010637a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010637f:	e9 f3 01 00 00       	jmp    80106577 <sys_unlink+0x21a>

  begin_op();
80106384:	e8 1e d5 ff ff       	call   801038a7 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80106389:	8b 45 c0             	mov    -0x40(%ebp),%eax
8010638c:	8d 55 c6             	lea    -0x3a(%ebp),%edx
8010638f:	89 54 24 04          	mov    %edx,0x4(%esp)
80106393:	89 04 24             	mov    %eax,(%esp)
80106396:	e8 29 c4 ff ff       	call   801027c4 <nameiparent>
8010639b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010639e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063a2:	75 0f                	jne    801063b3 <sys_unlink+0x56>
    end_op();
801063a4:	e8 80 d5 ff ff       	call   80103929 <end_op>
    return -1;
801063a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063ae:	e9 c4 01 00 00       	jmp    80106577 <sys_unlink+0x21a>
  }

  ilock(dp);
801063b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063b6:	89 04 24             	mov    %eax,(%esp)
801063b9:	e8 69 b7 ff ff       	call   80101b27 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801063be:	c7 44 24 04 e3 a2 10 	movl   $0x8010a2e3,0x4(%esp)
801063c5:	80 
801063c6:	8d 45 c6             	lea    -0x3a(%ebp),%eax
801063c9:	89 04 24             	mov    %eax,(%esp)
801063cc:	e8 66 bf ff ff       	call   80102337 <namecmp>
801063d1:	85 c0                	test   %eax,%eax
801063d3:	0f 84 89 01 00 00    	je     80106562 <sys_unlink+0x205>
801063d9:	c7 44 24 04 e5 a2 10 	movl   $0x8010a2e5,0x4(%esp)
801063e0:	80 
801063e1:	8d 45 c6             	lea    -0x3a(%ebp),%eax
801063e4:	89 04 24             	mov    %eax,(%esp)
801063e7:	e8 4b bf ff ff       	call   80102337 <namecmp>
801063ec:	85 c0                	test   %eax,%eax
801063ee:	0f 84 6e 01 00 00    	je     80106562 <sys_unlink+0x205>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801063f4:	8d 45 bc             	lea    -0x44(%ebp),%eax
801063f7:	89 44 24 08          	mov    %eax,0x8(%esp)
801063fb:	8d 45 c6             	lea    -0x3a(%ebp),%eax
801063fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80106402:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106405:	89 04 24             	mov    %eax,(%esp)
80106408:	e8 4c bf ff ff       	call   80102359 <dirlookup>
8010640d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106410:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106414:	75 05                	jne    8010641b <sys_unlink+0xbe>
    goto bad;
80106416:	e9 47 01 00 00       	jmp    80106562 <sys_unlink+0x205>
  ilock(ip);
8010641b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010641e:	89 04 24             	mov    %eax,(%esp)
80106421:	e8 01 b7 ff ff       	call   80101b27 <ilock>

  if(ip->nlink < 1)
80106426:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106429:	66 8b 40 56          	mov    0x56(%eax),%ax
8010642d:	66 85 c0             	test   %ax,%ax
80106430:	7f 0c                	jg     8010643e <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
80106432:	c7 04 24 e8 a2 10 80 	movl   $0x8010a2e8,(%esp)
80106439:	e8 16 a1 ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010643e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106441:	8b 40 50             	mov    0x50(%eax),%eax
80106444:	66 83 f8 01          	cmp    $0x1,%ax
80106448:	75 1f                	jne    80106469 <sys_unlink+0x10c>
8010644a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010644d:	89 04 24             	mov    %eax,(%esp)
80106450:	e8 9b fe ff ff       	call   801062f0 <isdirempty>
80106455:	85 c0                	test   %eax,%eax
80106457:	75 10                	jne    80106469 <sys_unlink+0x10c>
    iunlockput(ip);
80106459:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010645c:	89 04 24             	mov    %eax,(%esp)
8010645f:	e8 c2 b8 ff ff       	call   80101d26 <iunlockput>
    goto bad;
80106464:	e9 f9 00 00 00       	jmp    80106562 <sys_unlink+0x205>
  }

  memset(&de, 0, sizeof(de));
80106469:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80106470:	00 
80106471:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106478:	00 
80106479:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010647c:	89 04 24             	mov    %eax,(%esp)
8010647f:	e8 a6 f5 ff ff       	call   80105a2a <memset>
  int z = writei(dp, (char*)&de, off, sizeof(de));
80106484:	8b 45 bc             	mov    -0x44(%ebp),%eax
80106487:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010648e:	00 
8010648f:	89 44 24 08          	mov    %eax,0x8(%esp)
80106493:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80106496:	89 44 24 04          	mov    %eax,0x4(%esp)
8010649a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010649d:	89 04 24             	mov    %eax,(%esp)
801064a0:	e8 7d bc ff ff       	call   80102122 <writei>
801064a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(z != sizeof(de))
801064a8:	83 7d ec 10          	cmpl   $0x10,-0x14(%ebp)
801064ac:	74 0c                	je     801064ba <sys_unlink+0x15d>
    panic("unlink: writei");
801064ae:	c7 04 24 fa a2 10 80 	movl   $0x8010a2fa,(%esp)
801064b5:	e8 9a a0 ff ff       	call   80100554 <panic>

  char *c_name = myproc()->cont->name;
801064ba:	e8 e8 e0 ff ff       	call   801045a7 <myproc>
801064bf:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801064c5:	83 c0 1c             	add    $0x1c,%eax
801064c8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int x = find(c_name);
801064cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064ce:	89 04 24             	mov    %eax,(%esp)
801064d1:	e8 db 30 00 00       	call   801095b1 <find>
801064d6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  // cprintf("DECREMENTING %d \n", set);
  set_os(-ip->size);
801064d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064dc:	8b 40 58             	mov    0x58(%eax),%eax
801064df:	f7 d8                	neg    %eax
801064e1:	89 04 24             	mov    %eax,(%esp)
801064e4:	e8 f6 32 00 00       	call   801097df <set_os>
  set_curr_disk(-ip->size, x);
801064e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064ec:	8b 40 58             	mov    0x58(%eax),%eax
801064ef:	f7 d8                	neg    %eax
801064f1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801064f4:	89 54 24 04          	mov    %edx,0x4(%esp)
801064f8:	89 04 24             	mov    %eax,(%esp)
801064fb:	e8 d5 33 00 00       	call   801098d5 <set_curr_disk>
  if(ip->type == T_DIR){
80106500:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106503:	8b 40 50             	mov    0x50(%eax),%eax
80106506:	66 83 f8 01          	cmp    $0x1,%ax
8010650a:	75 1a                	jne    80106526 <sys_unlink+0x1c9>
    dp->nlink--;
8010650c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010650f:	66 8b 40 56          	mov    0x56(%eax),%ax
80106513:	48                   	dec    %eax
80106514:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106517:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
8010651b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010651e:	89 04 24             	mov    %eax,(%esp)
80106521:	e8 3e b4 ff ff       	call   80101964 <iupdate>
  }
  iunlockput(dp);
80106526:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106529:	89 04 24             	mov    %eax,(%esp)
8010652c:	e8 f5 b7 ff ff       	call   80101d26 <iunlockput>

  ip->nlink--;
80106531:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106534:	66 8b 40 56          	mov    0x56(%eax),%ax
80106538:	48                   	dec    %eax
80106539:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010653c:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80106540:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106543:	89 04 24             	mov    %eax,(%esp)
80106546:	e8 19 b4 ff ff       	call   80101964 <iupdate>
  iunlockput(ip);
8010654b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010654e:	89 04 24             	mov    %eax,(%esp)
80106551:	e8 d0 b7 ff ff       	call   80101d26 <iunlockput>

  end_op();
80106556:	e8 ce d3 ff ff       	call   80103929 <end_op>

  return 0;
8010655b:	b8 00 00 00 00       	mov    $0x0,%eax
80106560:	eb 15                	jmp    80106577 <sys_unlink+0x21a>

bad:
  iunlockput(dp);
80106562:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106565:	89 04 24             	mov    %eax,(%esp)
80106568:	e8 b9 b7 ff ff       	call   80101d26 <iunlockput>
  end_op();
8010656d:	e8 b7 d3 ff ff       	call   80103929 <end_op>
  return -1;
80106572:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106577:	c9                   	leave  
80106578:	c3                   	ret    

80106579 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80106579:	55                   	push   %ebp
8010657a:	89 e5                	mov    %esp,%ebp
8010657c:	83 ec 48             	sub    $0x48,%esp
8010657f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106582:	8b 55 10             	mov    0x10(%ebp),%edx
80106585:	8b 45 14             	mov    0x14(%ebp),%eax
80106588:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010658c:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106590:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106594:	8d 45 de             	lea    -0x22(%ebp),%eax
80106597:	89 44 24 04          	mov    %eax,0x4(%esp)
8010659b:	8b 45 08             	mov    0x8(%ebp),%eax
8010659e:	89 04 24             	mov    %eax,(%esp)
801065a1:	e8 1e c2 ff ff       	call   801027c4 <nameiparent>
801065a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801065a9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801065ad:	75 0a                	jne    801065b9 <create+0x40>
    return 0;
801065af:	b8 00 00 00 00       	mov    $0x0,%eax
801065b4:	e9 79 01 00 00       	jmp    80106732 <create+0x1b9>
  ilock(dp);
801065b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065bc:	89 04 24             	mov    %eax,(%esp)
801065bf:	e8 63 b5 ff ff       	call   80101b27 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
801065c4:	8d 45 ec             	lea    -0x14(%ebp),%eax
801065c7:	89 44 24 08          	mov    %eax,0x8(%esp)
801065cb:	8d 45 de             	lea    -0x22(%ebp),%eax
801065ce:	89 44 24 04          	mov    %eax,0x4(%esp)
801065d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065d5:	89 04 24             	mov    %eax,(%esp)
801065d8:	e8 7c bd ff ff       	call   80102359 <dirlookup>
801065dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
801065e0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065e4:	74 46                	je     8010662c <create+0xb3>
    iunlockput(dp);
801065e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065e9:	89 04 24             	mov    %eax,(%esp)
801065ec:	e8 35 b7 ff ff       	call   80101d26 <iunlockput>
    ilock(ip);
801065f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065f4:	89 04 24             	mov    %eax,(%esp)
801065f7:	e8 2b b5 ff ff       	call   80101b27 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801065fc:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106601:	75 14                	jne    80106617 <create+0x9e>
80106603:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106606:	8b 40 50             	mov    0x50(%eax),%eax
80106609:	66 83 f8 02          	cmp    $0x2,%ax
8010660d:	75 08                	jne    80106617 <create+0x9e>
      return ip;
8010660f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106612:	e9 1b 01 00 00       	jmp    80106732 <create+0x1b9>
    iunlockput(ip);
80106617:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010661a:	89 04 24             	mov    %eax,(%esp)
8010661d:	e8 04 b7 ff ff       	call   80101d26 <iunlockput>
    return 0;
80106622:	b8 00 00 00 00       	mov    $0x0,%eax
80106627:	e9 06 01 00 00       	jmp    80106732 <create+0x1b9>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
8010662c:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106630:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106633:	8b 00                	mov    (%eax),%eax
80106635:	89 54 24 04          	mov    %edx,0x4(%esp)
80106639:	89 04 24             	mov    %eax,(%esp)
8010663c:	e8 51 b2 ff ff       	call   80101892 <ialloc>
80106641:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106644:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106648:	75 0c                	jne    80106656 <create+0xdd>
    panic("create: ialloc");
8010664a:	c7 04 24 09 a3 10 80 	movl   $0x8010a309,(%esp)
80106651:	e8 fe 9e ff ff       	call   80100554 <panic>

  ilock(ip);
80106656:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106659:	89 04 24             	mov    %eax,(%esp)
8010665c:	e8 c6 b4 ff ff       	call   80101b27 <ilock>
  ip->major = major;
80106661:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106664:	8b 45 d0             	mov    -0x30(%ebp),%eax
80106667:	66 89 42 52          	mov    %ax,0x52(%edx)
  ip->minor = minor;
8010666b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010666e:	8b 45 cc             	mov    -0x34(%ebp),%eax
80106671:	66 89 42 54          	mov    %ax,0x54(%edx)
  ip->nlink = 1;
80106675:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106678:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
8010667e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106681:	89 04 24             	mov    %eax,(%esp)
80106684:	e8 db b2 ff ff       	call   80101964 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80106689:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010668e:	75 68                	jne    801066f8 <create+0x17f>
    dp->nlink++;  // for ".."
80106690:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106693:	66 8b 40 56          	mov    0x56(%eax),%ax
80106697:	40                   	inc    %eax
80106698:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010669b:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
8010669f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066a2:	89 04 24             	mov    %eax,(%esp)
801066a5:	e8 ba b2 ff ff       	call   80101964 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801066aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066ad:	8b 40 04             	mov    0x4(%eax),%eax
801066b0:	89 44 24 08          	mov    %eax,0x8(%esp)
801066b4:	c7 44 24 04 e3 a2 10 	movl   $0x8010a2e3,0x4(%esp)
801066bb:	80 
801066bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066bf:	89 04 24             	mov    %eax,(%esp)
801066c2:	e8 58 bd ff ff       	call   8010241f <dirlink>
801066c7:	85 c0                	test   %eax,%eax
801066c9:	78 21                	js     801066ec <create+0x173>
801066cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066ce:	8b 40 04             	mov    0x4(%eax),%eax
801066d1:	89 44 24 08          	mov    %eax,0x8(%esp)
801066d5:	c7 44 24 04 e5 a2 10 	movl   $0x8010a2e5,0x4(%esp)
801066dc:	80 
801066dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066e0:	89 04 24             	mov    %eax,(%esp)
801066e3:	e8 37 bd ff ff       	call   8010241f <dirlink>
801066e8:	85 c0                	test   %eax,%eax
801066ea:	79 0c                	jns    801066f8 <create+0x17f>
      panic("create dots");
801066ec:	c7 04 24 18 a3 10 80 	movl   $0x8010a318,(%esp)
801066f3:	e8 5c 9e ff ff       	call   80100554 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801066f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066fb:	8b 40 04             	mov    0x4(%eax),%eax
801066fe:	89 44 24 08          	mov    %eax,0x8(%esp)
80106702:	8d 45 de             	lea    -0x22(%ebp),%eax
80106705:	89 44 24 04          	mov    %eax,0x4(%esp)
80106709:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010670c:	89 04 24             	mov    %eax,(%esp)
8010670f:	e8 0b bd ff ff       	call   8010241f <dirlink>
80106714:	85 c0                	test   %eax,%eax
80106716:	79 0c                	jns    80106724 <create+0x1ab>
    panic("create: dirlink");
80106718:	c7 04 24 24 a3 10 80 	movl   $0x8010a324,(%esp)
8010671f:	e8 30 9e ff ff       	call   80100554 <panic>

  iunlockput(dp);
80106724:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106727:	89 04 24             	mov    %eax,(%esp)
8010672a:	e8 f7 b5 ff ff       	call   80101d26 <iunlockput>

  return ip;
8010672f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106732:	c9                   	leave  
80106733:	c3                   	ret    

80106734 <sys_open>:

int
sys_open(void)
{
80106734:	55                   	push   %ebp
80106735:	89 e5                	mov    %esp,%ebp
80106737:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010673a:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010673d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106741:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106748:	e8 a7 f6 ff ff       	call   80105df4 <argstr>
8010674d:	85 c0                	test   %eax,%eax
8010674f:	78 17                	js     80106768 <sys_open+0x34>
80106751:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106754:	89 44 24 04          	mov    %eax,0x4(%esp)
80106758:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010675f:	e8 f9 f5 ff ff       	call   80105d5d <argint>
80106764:	85 c0                	test   %eax,%eax
80106766:	79 0a                	jns    80106772 <sys_open+0x3e>
    return -1;
80106768:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010676d:	e9 64 01 00 00       	jmp    801068d6 <sys_open+0x1a2>

  begin_op();
80106772:	e8 30 d1 ff ff       	call   801038a7 <begin_op>

  if(omode & O_CREATE){
80106777:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010677a:	25 00 02 00 00       	and    $0x200,%eax
8010677f:	85 c0                	test   %eax,%eax
80106781:	74 3b                	je     801067be <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
80106783:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106786:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
8010678d:	00 
8010678e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106795:	00 
80106796:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
8010679d:	00 
8010679e:	89 04 24             	mov    %eax,(%esp)
801067a1:	e8 d3 fd ff ff       	call   80106579 <create>
801067a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801067a9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067ad:	75 6a                	jne    80106819 <sys_open+0xe5>
      end_op();
801067af:	e8 75 d1 ff ff       	call   80103929 <end_op>
      return -1;
801067b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067b9:	e9 18 01 00 00       	jmp    801068d6 <sys_open+0x1a2>
    }
  } else {
    if((ip = namei(path)) == 0){
801067be:	8b 45 e8             	mov    -0x18(%ebp),%eax
801067c1:	89 04 24             	mov    %eax,(%esp)
801067c4:	e8 d9 bf ff ff       	call   801027a2 <namei>
801067c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801067cc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067d0:	75 0f                	jne    801067e1 <sys_open+0xad>
      end_op();
801067d2:	e8 52 d1 ff ff       	call   80103929 <end_op>
      return -1;
801067d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067dc:	e9 f5 00 00 00       	jmp    801068d6 <sys_open+0x1a2>
    }
    ilock(ip);
801067e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067e4:	89 04 24             	mov    %eax,(%esp)
801067e7:	e8 3b b3 ff ff       	call   80101b27 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801067ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067ef:	8b 40 50             	mov    0x50(%eax),%eax
801067f2:	66 83 f8 01          	cmp    $0x1,%ax
801067f6:	75 21                	jne    80106819 <sys_open+0xe5>
801067f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801067fb:	85 c0                	test   %eax,%eax
801067fd:	74 1a                	je     80106819 <sys_open+0xe5>
      iunlockput(ip);
801067ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106802:	89 04 24             	mov    %eax,(%esp)
80106805:	e8 1c b5 ff ff       	call   80101d26 <iunlockput>
      end_op();
8010680a:	e8 1a d1 ff ff       	call   80103929 <end_op>
      return -1;
8010680f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106814:	e9 bd 00 00 00       	jmp    801068d6 <sys_open+0x1a2>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106819:	e8 e4 a8 ff ff       	call   80101102 <filealloc>
8010681e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106821:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106825:	74 14                	je     8010683b <sys_open+0x107>
80106827:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010682a:	89 04 24             	mov    %eax,(%esp)
8010682d:	e8 f6 f6 ff ff       	call   80105f28 <fdalloc>
80106832:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106835:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106839:	79 28                	jns    80106863 <sys_open+0x12f>
    if(f)
8010683b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010683f:	74 0b                	je     8010684c <sys_open+0x118>
      fileclose(f);
80106841:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106844:	89 04 24             	mov    %eax,(%esp)
80106847:	e8 5e a9 ff ff       	call   801011aa <fileclose>
    iunlockput(ip);
8010684c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010684f:	89 04 24             	mov    %eax,(%esp)
80106852:	e8 cf b4 ff ff       	call   80101d26 <iunlockput>
    end_op();
80106857:	e8 cd d0 ff ff       	call   80103929 <end_op>
    return -1;
8010685c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106861:	eb 73                	jmp    801068d6 <sys_open+0x1a2>
  }
  iunlock(ip);
80106863:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106866:	89 04 24             	mov    %eax,(%esp)
80106869:	e8 c3 b3 ff ff       	call   80101c31 <iunlock>
  end_op();
8010686e:	e8 b6 d0 ff ff       	call   80103929 <end_op>

  f->type = FD_INODE;
80106873:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106876:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
8010687c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010687f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106882:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106885:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106888:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
8010688f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106892:	83 e0 01             	and    $0x1,%eax
80106895:	85 c0                	test   %eax,%eax
80106897:	0f 94 c0             	sete   %al
8010689a:	88 c2                	mov    %al,%dl
8010689c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010689f:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801068a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801068a5:	83 e0 01             	and    $0x1,%eax
801068a8:	85 c0                	test   %eax,%eax
801068aa:	75 0a                	jne    801068b6 <sys_open+0x182>
801068ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801068af:	83 e0 02             	and    $0x2,%eax
801068b2:	85 c0                	test   %eax,%eax
801068b4:	74 07                	je     801068bd <sys_open+0x189>
801068b6:	b8 01 00 00 00       	mov    $0x1,%eax
801068bb:	eb 05                	jmp    801068c2 <sys_open+0x18e>
801068bd:	b8 00 00 00 00       	mov    $0x0,%eax
801068c2:	88 c2                	mov    %al,%dl
801068c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068c7:	88 50 09             	mov    %dl,0x9(%eax)
  f->path = path;
801068ca:	8b 55 e8             	mov    -0x18(%ebp),%edx
801068cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068d0:	89 50 18             	mov    %edx,0x18(%eax)
  return fd;
801068d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801068d6:	c9                   	leave  
801068d7:	c3                   	ret    

801068d8 <sys_mkdir>:

int
sys_mkdir(void)
{
801068d8:	55                   	push   %ebp
801068d9:	89 e5                	mov    %esp,%ebp
801068db:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
801068de:	e8 c4 cf ff ff       	call   801038a7 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801068e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801068e6:	89 44 24 04          	mov    %eax,0x4(%esp)
801068ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801068f1:	e8 fe f4 ff ff       	call   80105df4 <argstr>
801068f6:	85 c0                	test   %eax,%eax
801068f8:	78 2c                	js     80106926 <sys_mkdir+0x4e>
801068fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068fd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106904:	00 
80106905:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010690c:	00 
8010690d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106914:	00 
80106915:	89 04 24             	mov    %eax,(%esp)
80106918:	e8 5c fc ff ff       	call   80106579 <create>
8010691d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106920:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106924:	75 0c                	jne    80106932 <sys_mkdir+0x5a>
    end_op();
80106926:	e8 fe cf ff ff       	call   80103929 <end_op>
    return -1;
8010692b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106930:	eb 15                	jmp    80106947 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80106932:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106935:	89 04 24             	mov    %eax,(%esp)
80106938:	e8 e9 b3 ff ff       	call   80101d26 <iunlockput>
  end_op();
8010693d:	e8 e7 cf ff ff       	call   80103929 <end_op>
  return 0;
80106942:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106947:	c9                   	leave  
80106948:	c3                   	ret    

80106949 <sys_mknod>:

int
sys_mknod(void)
{
80106949:	55                   	push   %ebp
8010694a:	89 e5                	mov    %esp,%ebp
8010694c:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
8010694f:	e8 53 cf ff ff       	call   801038a7 <begin_op>
  if((argstr(0, &path)) < 0 ||
80106954:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106957:	89 44 24 04          	mov    %eax,0x4(%esp)
8010695b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106962:	e8 8d f4 ff ff       	call   80105df4 <argstr>
80106967:	85 c0                	test   %eax,%eax
80106969:	78 5e                	js     801069c9 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
8010696b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010696e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106972:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106979:	e8 df f3 ff ff       	call   80105d5d <argint>
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
8010697e:	85 c0                	test   %eax,%eax
80106980:	78 47                	js     801069c9 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106982:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106985:	89 44 24 04          	mov    %eax,0x4(%esp)
80106989:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106990:	e8 c8 f3 ff ff       	call   80105d5d <argint>
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106995:	85 c0                	test   %eax,%eax
80106997:	78 30                	js     801069c9 <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106999:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010699c:	0f bf c8             	movswl %ax,%ecx
8010699f:	8b 45 ec             	mov    -0x14(%ebp),%eax
801069a2:	0f bf d0             	movswl %ax,%edx
801069a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801069a8:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801069ac:	89 54 24 08          	mov    %edx,0x8(%esp)
801069b0:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801069b7:	00 
801069b8:	89 04 24             	mov    %eax,(%esp)
801069bb:	e8 b9 fb ff ff       	call   80106579 <create>
801069c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801069c3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801069c7:	75 0c                	jne    801069d5 <sys_mknod+0x8c>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
801069c9:	e8 5b cf ff ff       	call   80103929 <end_op>
    return -1;
801069ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069d3:	eb 15                	jmp    801069ea <sys_mknod+0xa1>
  }
  iunlockput(ip);
801069d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069d8:	89 04 24             	mov    %eax,(%esp)
801069db:	e8 46 b3 ff ff       	call   80101d26 <iunlockput>
  end_op();
801069e0:	e8 44 cf ff ff       	call   80103929 <end_op>
  return 0;
801069e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801069ea:	c9                   	leave  
801069eb:	c3                   	ret    

801069ec <sys_chdir>:

int
sys_chdir(void)
{
801069ec:	55                   	push   %ebp
801069ed:	89 e5                	mov    %esp,%ebp
801069ef:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801069f2:	e8 b0 db ff ff       	call   801045a7 <myproc>
801069f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
801069fa:	e8 a8 ce ff ff       	call   801038a7 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801069ff:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106a02:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a06:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a0d:	e8 e2 f3 ff ff       	call   80105df4 <argstr>
80106a12:	85 c0                	test   %eax,%eax
80106a14:	78 14                	js     80106a2a <sys_chdir+0x3e>
80106a16:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106a19:	89 04 24             	mov    %eax,(%esp)
80106a1c:	e8 81 bd ff ff       	call   801027a2 <namei>
80106a21:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106a24:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106a28:	75 0c                	jne    80106a36 <sys_chdir+0x4a>
    end_op();
80106a2a:	e8 fa ce ff ff       	call   80103929 <end_op>
    return -1;
80106a2f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a34:	eb 5a                	jmp    80106a90 <sys_chdir+0xa4>
  }
  ilock(ip);
80106a36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a39:	89 04 24             	mov    %eax,(%esp)
80106a3c:	e8 e6 b0 ff ff       	call   80101b27 <ilock>
  if(ip->type != T_DIR){
80106a41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a44:	8b 40 50             	mov    0x50(%eax),%eax
80106a47:	66 83 f8 01          	cmp    $0x1,%ax
80106a4b:	74 17                	je     80106a64 <sys_chdir+0x78>
    iunlockput(ip);
80106a4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a50:	89 04 24             	mov    %eax,(%esp)
80106a53:	e8 ce b2 ff ff       	call   80101d26 <iunlockput>
    end_op();
80106a58:	e8 cc ce ff ff       	call   80103929 <end_op>
    return -1;
80106a5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a62:	eb 2c                	jmp    80106a90 <sys_chdir+0xa4>
  }
  iunlock(ip);
80106a64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a67:	89 04 24             	mov    %eax,(%esp)
80106a6a:	e8 c2 b1 ff ff       	call   80101c31 <iunlock>
  iput(curproc->cwd);
80106a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a72:	8b 40 68             	mov    0x68(%eax),%eax
80106a75:	89 04 24             	mov    %eax,(%esp)
80106a78:	e8 f8 b1 ff ff       	call   80101c75 <iput>
  end_op();
80106a7d:	e8 a7 ce ff ff       	call   80103929 <end_op>
  curproc->cwd = ip;
80106a82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a85:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106a88:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106a8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106a90:	c9                   	leave  
80106a91:	c3                   	ret    

80106a92 <sys_exec>:

int
sys_exec(void)
{
80106a92:	55                   	push   %ebp
80106a93:	89 e5                	mov    %esp,%ebp
80106a95:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106a9b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a9e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106aa2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106aa9:	e8 46 f3 ff ff       	call   80105df4 <argstr>
80106aae:	85 c0                	test   %eax,%eax
80106ab0:	78 1a                	js     80106acc <sys_exec+0x3a>
80106ab2:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106ab8:	89 44 24 04          	mov    %eax,0x4(%esp)
80106abc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106ac3:	e8 95 f2 ff ff       	call   80105d5d <argint>
80106ac8:	85 c0                	test   %eax,%eax
80106aca:	79 0a                	jns    80106ad6 <sys_exec+0x44>
    return -1;
80106acc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ad1:	e9 c7 00 00 00       	jmp    80106b9d <sys_exec+0x10b>
  }
  memset(argv, 0, sizeof(argv));
80106ad6:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106add:	00 
80106ade:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106ae5:	00 
80106ae6:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106aec:	89 04 24             	mov    %eax,(%esp)
80106aef:	e8 36 ef ff ff       	call   80105a2a <memset>
  for(i=0;; i++){
80106af4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106afe:	83 f8 1f             	cmp    $0x1f,%eax
80106b01:	76 0a                	jbe    80106b0d <sys_exec+0x7b>
      return -1;
80106b03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b08:	e9 90 00 00 00       	jmp    80106b9d <sys_exec+0x10b>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b10:	c1 e0 02             	shl    $0x2,%eax
80106b13:	89 c2                	mov    %eax,%edx
80106b15:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106b1b:	01 c2                	add    %eax,%edx
80106b1d:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106b23:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b27:	89 14 24             	mov    %edx,(%esp)
80106b2a:	e8 8d f1 ff ff       	call   80105cbc <fetchint>
80106b2f:	85 c0                	test   %eax,%eax
80106b31:	79 07                	jns    80106b3a <sys_exec+0xa8>
      return -1;
80106b33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b38:	eb 63                	jmp    80106b9d <sys_exec+0x10b>
    if(uarg == 0){
80106b3a:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106b40:	85 c0                	test   %eax,%eax
80106b42:	75 26                	jne    80106b6a <sys_exec+0xd8>
      argv[i] = 0;
80106b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b47:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106b4e:	00 00 00 00 
      break;
80106b52:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106b53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b56:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106b5c:	89 54 24 04          	mov    %edx,0x4(%esp)
80106b60:	89 04 24             	mov    %eax,(%esp)
80106b63:	e8 d8 a0 ff ff       	call   80100c40 <exec>
80106b68:	eb 33                	jmp    80106b9d <sys_exec+0x10b>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106b6a:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106b70:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106b73:	c1 e2 02             	shl    $0x2,%edx
80106b76:	01 c2                	add    %eax,%edx
80106b78:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106b7e:	89 54 24 04          	mov    %edx,0x4(%esp)
80106b82:	89 04 24             	mov    %eax,(%esp)
80106b85:	e8 71 f1 ff ff       	call   80105cfb <fetchstr>
80106b8a:	85 c0                	test   %eax,%eax
80106b8c:	79 07                	jns    80106b95 <sys_exec+0x103>
      return -1;
80106b8e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b93:	eb 08                	jmp    80106b9d <sys_exec+0x10b>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106b95:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106b98:	e9 5e ff ff ff       	jmp    80106afb <sys_exec+0x69>
  return exec(path, argv);
}
80106b9d:	c9                   	leave  
80106b9e:	c3                   	ret    

80106b9f <sys_pipe>:

int
sys_pipe(void)
{
80106b9f:	55                   	push   %ebp
80106ba0:	89 e5                	mov    %esp,%ebp
80106ba2:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106ba5:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106bac:	00 
80106bad:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106bb0:	89 44 24 04          	mov    %eax,0x4(%esp)
80106bb4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106bbb:	e8 ca f1 ff ff       	call   80105d8a <argptr>
80106bc0:	85 c0                	test   %eax,%eax
80106bc2:	79 0a                	jns    80106bce <sys_pipe+0x2f>
    return -1;
80106bc4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106bc9:	e9 9a 00 00 00       	jmp    80106c68 <sys_pipe+0xc9>
  if(pipealloc(&rf, &wf) < 0)
80106bce:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106bd1:	89 44 24 04          	mov    %eax,0x4(%esp)
80106bd5:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106bd8:	89 04 24             	mov    %eax,(%esp)
80106bdb:	e8 1c d5 ff ff       	call   801040fc <pipealloc>
80106be0:	85 c0                	test   %eax,%eax
80106be2:	79 07                	jns    80106beb <sys_pipe+0x4c>
    return -1;
80106be4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106be9:	eb 7d                	jmp    80106c68 <sys_pipe+0xc9>
  fd0 = -1;
80106beb:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106bf2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106bf5:	89 04 24             	mov    %eax,(%esp)
80106bf8:	e8 2b f3 ff ff       	call   80105f28 <fdalloc>
80106bfd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106c00:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106c04:	78 14                	js     80106c1a <sys_pipe+0x7b>
80106c06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c09:	89 04 24             	mov    %eax,(%esp)
80106c0c:	e8 17 f3 ff ff       	call   80105f28 <fdalloc>
80106c11:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106c14:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106c18:	79 36                	jns    80106c50 <sys_pipe+0xb1>
    if(fd0 >= 0)
80106c1a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106c1e:	78 13                	js     80106c33 <sys_pipe+0x94>
      myproc()->ofile[fd0] = 0;
80106c20:	e8 82 d9 ff ff       	call   801045a7 <myproc>
80106c25:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106c28:	83 c2 08             	add    $0x8,%edx
80106c2b:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106c32:	00 
    fileclose(rf);
80106c33:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106c36:	89 04 24             	mov    %eax,(%esp)
80106c39:	e8 6c a5 ff ff       	call   801011aa <fileclose>
    fileclose(wf);
80106c3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c41:	89 04 24             	mov    %eax,(%esp)
80106c44:	e8 61 a5 ff ff       	call   801011aa <fileclose>
    return -1;
80106c49:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c4e:	eb 18                	jmp    80106c68 <sys_pipe+0xc9>
  }
  fd[0] = fd0;
80106c50:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106c53:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106c56:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106c58:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106c5b:	8d 50 04             	lea    0x4(%eax),%edx
80106c5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c61:	89 02                	mov    %eax,(%edx)
  return 0;
80106c63:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106c68:	c9                   	leave  
80106c69:	c3                   	ret    
	...

80106c6c <sys_fork>:
#define NULL ((void*)0)


int
sys_fork(void)
{
80106c6c:	55                   	push   %ebp
80106c6d:	89 e5                	mov    %esp,%ebp
80106c6f:	83 ec 28             	sub    $0x28,%esp
  int x = find(myproc()->cont->name);
80106c72:	e8 30 d9 ff ff       	call   801045a7 <myproc>
80106c77:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106c7d:	83 c0 1c             	add    $0x1c,%eax
80106c80:	89 04 24             	mov    %eax,(%esp)
80106c83:	e8 29 29 00 00       	call   801095b1 <find>
80106c88:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(x >= 0){
80106c8b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106c8f:	78 51                	js     80106ce2 <sys_fork+0x76>
    int before = get_curr_proc(x);
80106c91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c94:	89 04 24             	mov    %eax,(%esp)
80106c97:	e8 4f 2a 00 00       	call   801096eb <get_curr_proc>
80106c9c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    set_curr_proc(1, x);
80106c9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ca2:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ca6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106cad:	e8 a9 2c 00 00       	call   8010995b <set_curr_proc>
    int after = get_curr_proc(x);
80106cb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cb5:	89 04 24             	mov    %eax,(%esp)
80106cb8:	e8 2e 2a 00 00       	call   801096eb <get_curr_proc>
80106cbd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(after == before){
80106cc0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106cc3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80106cc6:	75 1a                	jne    80106ce2 <sys_fork+0x76>
      cstop_container_helper(myproc()->cont);
80106cc8:	e8 da d8 ff ff       	call   801045a7 <myproc>
80106ccd:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106cd3:	89 04 24             	mov    %eax,(%esp)
80106cd6:	e8 25 e5 ff ff       	call   80105200 <cstop_container_helper>
      return -1;
80106cdb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ce0:	eb 05                	jmp    80106ce7 <sys_fork+0x7b>
    }
  }
  return fork();
80106ce2:	e8 cf db ff ff       	call   801048b6 <fork>
}
80106ce7:	c9                   	leave  
80106ce8:	c3                   	ret    

80106ce9 <sys_exit>:

int
sys_exit(void)
{
80106ce9:	55                   	push   %ebp
80106cea:	89 e5                	mov    %esp,%ebp
80106cec:	83 ec 28             	sub    $0x28,%esp
  int x = find(myproc()->cont->name);
80106cef:	e8 b3 d8 ff ff       	call   801045a7 <myproc>
80106cf4:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106cfa:	83 c0 1c             	add    $0x1c,%eax
80106cfd:	89 04 24             	mov    %eax,(%esp)
80106d00:	e8 ac 28 00 00       	call   801095b1 <find>
80106d05:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(x >= 0){
80106d08:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106d0c:	78 13                	js     80106d21 <sys_exit+0x38>
    set_curr_proc(-1, x);
80106d0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d11:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d15:	c7 04 24 ff ff ff ff 	movl   $0xffffffff,(%esp)
80106d1c:	e8 3a 2c 00 00       	call   8010995b <set_curr_proc>
  }
  exit();
80106d21:	e8 12 dd ff ff       	call   80104a38 <exit>
  return 0;  // not reached
80106d26:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106d2b:	c9                   	leave  
80106d2c:	c3                   	ret    

80106d2d <sys_wait>:

int
sys_wait(void)
{
80106d2d:	55                   	push   %ebp
80106d2e:	89 e5                	mov    %esp,%ebp
80106d30:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106d33:	e8 44 de ff ff       	call   80104b7c <wait>
}
80106d38:	c9                   	leave  
80106d39:	c3                   	ret    

80106d3a <sys_kill>:

int
sys_kill(void)
{
80106d3a:	55                   	push   %ebp
80106d3b:	89 e5                	mov    %esp,%ebp
80106d3d:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106d40:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106d43:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d47:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106d4e:	e8 0a f0 ff ff       	call   80105d5d <argint>
80106d53:	85 c0                	test   %eax,%eax
80106d55:	79 07                	jns    80106d5e <sys_kill+0x24>
    return -1;
80106d57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d5c:	eb 0b                	jmp    80106d69 <sys_kill+0x2f>
  return kill(pid);
80106d5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d61:	89 04 24             	mov    %eax,(%esp)
80106d64:	e8 60 e2 ff ff       	call   80104fc9 <kill>
}
80106d69:	c9                   	leave  
80106d6a:	c3                   	ret    

80106d6b <sys_getpid>:

int
sys_getpid(void)
{
80106d6b:	55                   	push   %ebp
80106d6c:	89 e5                	mov    %esp,%ebp
80106d6e:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106d71:	e8 31 d8 ff ff       	call   801045a7 <myproc>
80106d76:	8b 40 10             	mov    0x10(%eax),%eax
}
80106d79:	c9                   	leave  
80106d7a:	c3                   	ret    

80106d7b <sys_sbrk>:

int
sys_sbrk(void)
{
80106d7b:	55                   	push   %ebp
80106d7c:	89 e5                	mov    %esp,%ebp
80106d7e:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106d81:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106d84:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d88:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106d8f:	e8 c9 ef ff ff       	call   80105d5d <argint>
80106d94:	85 c0                	test   %eax,%eax
80106d96:	79 07                	jns    80106d9f <sys_sbrk+0x24>
    return -1;
80106d98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d9d:	eb 23                	jmp    80106dc2 <sys_sbrk+0x47>
  addr = myproc()->sz;
80106d9f:	e8 03 d8 ff ff       	call   801045a7 <myproc>
80106da4:	8b 00                	mov    (%eax),%eax
80106da6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106da9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106dac:	89 04 24             	mov    %eax,(%esp)
80106daf:	e8 64 da ff ff       	call   80104818 <growproc>
80106db4:	85 c0                	test   %eax,%eax
80106db6:	79 07                	jns    80106dbf <sys_sbrk+0x44>
    return -1;
80106db8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106dbd:	eb 03                	jmp    80106dc2 <sys_sbrk+0x47>
  return addr;
80106dbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106dc2:	c9                   	leave  
80106dc3:	c3                   	ret    

80106dc4 <sys_sleep>:

int
sys_sleep(void)
{
80106dc4:	55                   	push   %ebp
80106dc5:	89 e5                	mov    %esp,%ebp
80106dc7:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106dca:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106dcd:	89 44 24 04          	mov    %eax,0x4(%esp)
80106dd1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106dd8:	e8 80 ef ff ff       	call   80105d5d <argint>
80106ddd:	85 c0                	test   %eax,%eax
80106ddf:	79 07                	jns    80106de8 <sys_sleep+0x24>
    return -1;
80106de1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106de6:	eb 6b                	jmp    80106e53 <sys_sleep+0x8f>
  acquire(&tickslock);
80106de8:	c7 04 24 00 85 11 80 	movl   $0x80118500,(%esp)
80106def:	e8 d3 e9 ff ff       	call   801057c7 <acquire>
  ticks0 = ticks;
80106df4:	a1 40 8d 11 80       	mov    0x80118d40,%eax
80106df9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106dfc:	eb 33                	jmp    80106e31 <sys_sleep+0x6d>
    if(myproc()->killed){
80106dfe:	e8 a4 d7 ff ff       	call   801045a7 <myproc>
80106e03:	8b 40 24             	mov    0x24(%eax),%eax
80106e06:	85 c0                	test   %eax,%eax
80106e08:	74 13                	je     80106e1d <sys_sleep+0x59>
      release(&tickslock);
80106e0a:	c7 04 24 00 85 11 80 	movl   $0x80118500,(%esp)
80106e11:	e8 1b ea ff ff       	call   80105831 <release>
      return -1;
80106e16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e1b:	eb 36                	jmp    80106e53 <sys_sleep+0x8f>
    }
    sleep(&ticks, &tickslock);
80106e1d:	c7 44 24 04 00 85 11 	movl   $0x80118500,0x4(%esp)
80106e24:	80 
80106e25:	c7 04 24 40 8d 11 80 	movl   $0x80118d40,(%esp)
80106e2c:	e8 96 e0 ff ff       	call   80104ec7 <sleep>

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106e31:	a1 40 8d 11 80       	mov    0x80118d40,%eax
80106e36:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106e39:	89 c2                	mov    %eax,%edx
80106e3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106e3e:	39 c2                	cmp    %eax,%edx
80106e40:	72 bc                	jb     80106dfe <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106e42:	c7 04 24 00 85 11 80 	movl   $0x80118500,(%esp)
80106e49:	e8 e3 e9 ff ff       	call   80105831 <release>
  return 0;
80106e4e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106e53:	c9                   	leave  
80106e54:	c3                   	ret    

80106e55 <sys_cstop>:

void sys_cstop(){
80106e55:	55                   	push   %ebp
80106e56:	89 e5                	mov    %esp,%ebp
80106e58:	53                   	push   %ebx
80106e59:	83 ec 24             	sub    $0x24,%esp

  char* name;
  argstr(0, &name);
80106e5c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106e5f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e63:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106e6a:	e8 85 ef ff ff       	call   80105df4 <argstr>

  if(myproc()->cont != NULL){
80106e6f:	e8 33 d7 ff ff       	call   801045a7 <myproc>
80106e74:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106e7a:	85 c0                	test   %eax,%eax
80106e7c:	74 72                	je     80106ef0 <sys_cstop+0x9b>
    struct container* cont = myproc()->cont;
80106e7e:	e8 24 d7 ff ff       	call   801045a7 <myproc>
80106e83:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106e89:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(strlen(name) == strlen(cont->name) && strncmp(name, cont->name, strlen(name)) == 0){
80106e8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106e8f:	89 04 24             	mov    %eax,(%esp)
80106e92:	e8 e6 ed ff ff       	call   80105c7d <strlen>
80106e97:	89 c3                	mov    %eax,%ebx
80106e99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e9c:	83 c0 1c             	add    $0x1c,%eax
80106e9f:	89 04 24             	mov    %eax,(%esp)
80106ea2:	e8 d6 ed ff ff       	call   80105c7d <strlen>
80106ea7:	39 c3                	cmp    %eax,%ebx
80106ea9:	75 37                	jne    80106ee2 <sys_cstop+0x8d>
80106eab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106eae:	89 04 24             	mov    %eax,(%esp)
80106eb1:	e8 c7 ed ff ff       	call   80105c7d <strlen>
80106eb6:	89 c2                	mov    %eax,%edx
80106eb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ebb:	8d 48 1c             	lea    0x1c(%eax),%ecx
80106ebe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ec1:	89 54 24 08          	mov    %edx,0x8(%esp)
80106ec5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
80106ec9:	89 04 24             	mov    %eax,(%esp)
80106ecc:	e8 c1 ec ff ff       	call   80105b92 <strncmp>
80106ed1:	85 c0                	test   %eax,%eax
80106ed3:	75 0d                	jne    80106ee2 <sys_cstop+0x8d>
      cstop_container_helper(cont);
80106ed5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ed8:	89 04 24             	mov    %eax,(%esp)
80106edb:	e8 20 e3 ff ff       	call   80105200 <cstop_container_helper>
80106ee0:	eb 19                	jmp    80106efb <sys_cstop+0xa6>
      //stop the processes
    }
    else{
      cprintf("You are not authorized to do this.\n");
80106ee2:	c7 04 24 34 a3 10 80 	movl   $0x8010a334,(%esp)
80106ee9:	e8 d3 94 ff ff       	call   801003c1 <cprintf>
80106eee:	eb 0b                	jmp    80106efb <sys_cstop+0xa6>
    }
  }
  else{
    cstop_helper(name);
80106ef0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ef3:	89 04 24             	mov    %eax,(%esp)
80106ef6:	e8 6c e3 ff ff       	call   80105267 <cstop_helper>
  }

  //kill the processes with name as the id

}
80106efb:	83 c4 24             	add    $0x24,%esp
80106efe:	5b                   	pop    %ebx
80106eff:	5d                   	pop    %ebp
80106f00:	c3                   	ret    

80106f01 <sys_set_root_inode>:

void sys_set_root_inode(void){
80106f01:	55                   	push   %ebp
80106f02:	89 e5                	mov    %esp,%ebp
80106f04:	83 ec 28             	sub    $0x28,%esp

  char* name;
  argstr(0,&name);
80106f07:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106f0a:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f0e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106f15:	e8 da ee ff ff       	call   80105df4 <argstr>

  set_root_inode(name);
80106f1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f1d:	89 04 24             	mov    %eax,(%esp)
80106f20:	e8 36 25 00 00       	call   8010945b <set_root_inode>
  cprintf("success\n");
80106f25:	c7 04 24 58 a3 10 80 	movl   $0x8010a358,(%esp)
80106f2c:	e8 90 94 ff ff       	call   801003c1 <cprintf>

}
80106f31:	c9                   	leave  
80106f32:	c3                   	ret    

80106f33 <sys_ps>:

void sys_ps(void){
80106f33:	55                   	push   %ebp
80106f34:	89 e5                	mov    %esp,%ebp
80106f36:	83 ec 28             	sub    $0x28,%esp

  struct container* cont = myproc()->cont;
80106f39:	e8 69 d6 ff ff       	call   801045a7 <myproc>
80106f3e:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106f44:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(cont == NULL){
80106f47:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106f4b:	75 07                	jne    80106f54 <sys_ps+0x21>
    procdump();
80106f4d:	e8 56 e1 ff ff       	call   801050a8 <procdump>
80106f52:	eb 0e                	jmp    80106f62 <sys_ps+0x2f>
  }
  else{
    // cprintf("passing in %s as name for c_procdump.\n", cont->name);
    c_procdump(cont->name);
80106f54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f57:	83 c0 1c             	add    $0x1c,%eax
80106f5a:	89 04 24             	mov    %eax,(%esp)
80106f5d:	e8 9b e3 ff ff       	call   801052fd <c_procdump>
  }
}
80106f62:	c9                   	leave  
80106f63:	c3                   	ret    

80106f64 <sys_container_init>:

void sys_container_init(){
80106f64:	55                   	push   %ebp
80106f65:	89 e5                	mov    %esp,%ebp
80106f67:	83 ec 08             	sub    $0x8,%esp
  container_init();
80106f6a:	e8 62 2b 00 00       	call   80109ad1 <container_init>
}
80106f6f:	c9                   	leave  
80106f70:	c3                   	ret    

80106f71 <sys_is_full>:

int sys_is_full(void){
80106f71:	55                   	push   %ebp
80106f72:	89 e5                	mov    %esp,%ebp
80106f74:	83 ec 08             	sub    $0x8,%esp
  return is_full();
80106f77:	e8 ed 25 00 00       	call   80109569 <is_full>
}
80106f7c:	c9                   	leave  
80106f7d:	c3                   	ret    

80106f7e <sys_find>:

int sys_find(void){
80106f7e:	55                   	push   %ebp
80106f7f:	89 e5                	mov    %esp,%ebp
80106f81:	83 ec 28             	sub    $0x28,%esp
  char* name;
  argstr(0, &name);
80106f84:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106f87:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f8b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106f92:	e8 5d ee ff ff       	call   80105df4 <argstr>

  return find(name);
80106f97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f9a:	89 04 24             	mov    %eax,(%esp)
80106f9d:	e8 0f 26 00 00       	call   801095b1 <find>
}
80106fa2:	c9                   	leave  
80106fa3:	c3                   	ret    

80106fa4 <sys_get_name>:

void sys_get_name(void){
80106fa4:	55                   	push   %ebp
80106fa5:	89 e5                	mov    %esp,%ebp
80106fa7:	83 ec 28             	sub    $0x28,%esp

  int vc_num;
  char* name;
  argint(0, &vc_num);
80106faa:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106fad:	89 44 24 04          	mov    %eax,0x4(%esp)
80106fb1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106fb8:	e8 a0 ed ff ff       	call   80105d5d <argint>
  argstr(1, &name);
80106fbd:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106fc0:	89 44 24 04          	mov    %eax,0x4(%esp)
80106fc4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106fcb:	e8 24 ee ff ff       	call   80105df4 <argstr>

  get_name(vc_num, name);
80106fd0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106fd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fd6:	89 54 24 04          	mov    %edx,0x4(%esp)
80106fda:	89 04 24             	mov    %eax,(%esp)
80106fdd:	e8 b4 24 00 00       	call   80109496 <get_name>
}
80106fe2:	c9                   	leave  
80106fe3:	c3                   	ret    

80106fe4 <sys_get_max_proc>:

int sys_get_max_proc(void){
80106fe4:	55                   	push   %ebp
80106fe5:	89 e5                	mov    %esp,%ebp
80106fe7:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106fea:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106fed:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ff1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106ff8:	e8 60 ed ff ff       	call   80105d5d <argint>
  return get_max_proc(vc_num);  
80106ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107000:	89 04 24             	mov    %eax,(%esp)
80107003:	e8 11 26 00 00       	call   80109619 <get_max_proc>
}
80107008:	c9                   	leave  
80107009:	c3                   	ret    

8010700a <sys_get_os>:

int sys_get_os(void){
8010700a:	55                   	push   %ebp
8010700b:	89 e5                	mov    %esp,%ebp
8010700d:	83 ec 08             	sub    $0x8,%esp
  return get_os();
80107010:	e8 3c 26 00 00       	call   80109651 <get_os>
}
80107015:	c9                   	leave  
80107016:	c3                   	ret    

80107017 <sys_get_max_mem>:

int sys_get_max_mem(void){
80107017:	55                   	push   %ebp
80107018:	89 e5                	mov    %esp,%ebp
8010701a:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
8010701d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107020:	89 44 24 04          	mov    %eax,0x4(%esp)
80107024:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010702b:	e8 2d ed ff ff       	call   80105d5d <argint>


  return get_max_mem(vc_num);
80107030:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107033:	89 04 24             	mov    %eax,(%esp)
80107036:	e8 40 26 00 00       	call   8010967b <get_max_mem>
}
8010703b:	c9                   	leave  
8010703c:	c3                   	ret    

8010703d <sys_get_max_disk>:

int sys_get_max_disk(void){
8010703d:	55                   	push   %ebp
8010703e:	89 e5                	mov    %esp,%ebp
80107040:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80107043:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107046:	89 44 24 04          	mov    %eax,0x4(%esp)
8010704a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107051:	e8 07 ed ff ff       	call   80105d5d <argint>


  return get_max_disk(vc_num);
80107056:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107059:	89 04 24             	mov    %eax,(%esp)
8010705c:	e8 52 26 00 00       	call   801096b3 <get_max_disk>

}
80107061:	c9                   	leave  
80107062:	c3                   	ret    

80107063 <sys_get_curr_proc>:

int sys_get_curr_proc(void){
80107063:	55                   	push   %ebp
80107064:	89 e5                	mov    %esp,%ebp
80107066:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80107069:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010706c:	89 44 24 04          	mov    %eax,0x4(%esp)
80107070:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107077:	e8 e1 ec ff ff       	call   80105d5d <argint>


  return get_curr_proc(vc_num);
8010707c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010707f:	89 04 24             	mov    %eax,(%esp)
80107082:	e8 64 26 00 00       	call   801096eb <get_curr_proc>
}
80107087:	c9                   	leave  
80107088:	c3                   	ret    

80107089 <sys_get_curr_mem>:

int sys_get_curr_mem(void){
80107089:	55                   	push   %ebp
8010708a:	89 e5                	mov    %esp,%ebp
8010708c:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
8010708f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107092:	89 44 24 04          	mov    %eax,0x4(%esp)
80107096:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010709d:	e8 bb ec ff ff       	call   80105d5d <argint>


  return get_curr_mem(vc_num);
801070a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070a5:	89 04 24             	mov    %eax,(%esp)
801070a8:	e8 76 26 00 00       	call   80109723 <get_curr_mem>
}
801070ad:	c9                   	leave  
801070ae:	c3                   	ret    

801070af <sys_get_curr_disk>:

int sys_get_curr_disk(void){
801070af:	55                   	push   %ebp
801070b0:	89 e5                	mov    %esp,%ebp
801070b2:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
801070b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801070b8:	89 44 24 04          	mov    %eax,0x4(%esp)
801070bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801070c3:	e8 95 ec ff ff       	call   80105d5d <argint>


  return get_curr_disk(vc_num);
801070c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070cb:	89 04 24             	mov    %eax,(%esp)
801070ce:	e8 88 26 00 00       	call   8010975b <get_curr_disk>
}
801070d3:	c9                   	leave  
801070d4:	c3                   	ret    

801070d5 <sys_set_name>:

void sys_set_name(void){
801070d5:	55                   	push   %ebp
801070d6:	89 e5                	mov    %esp,%ebp
801070d8:	83 ec 28             	sub    $0x28,%esp
  char* name;
  argstr(0, &name);
801070db:	8d 45 f4             	lea    -0xc(%ebp),%eax
801070de:	89 44 24 04          	mov    %eax,0x4(%esp)
801070e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801070e9:	e8 06 ed ff ff       	call   80105df4 <argstr>

  int vc_num;
  argint(1, &vc_num);
801070ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
801070f1:	89 44 24 04          	mov    %eax,0x4(%esp)
801070f5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801070fc:	e8 5c ec ff ff       	call   80105d5d <argint>

  // myproc()->cont = get_container(vc_num);
  // cprintf("succ");

  set_name(name, vc_num);
80107101:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107104:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107107:	89 54 24 04          	mov    %edx,0x4(%esp)
8010710b:	89 04 24             	mov    %eax,(%esp)
8010710e:	e8 80 26 00 00       	call   80109793 <set_name>
  //cprintf("Done setting name.\n");
}
80107113:	c9                   	leave  
80107114:	c3                   	ret    

80107115 <sys_cont_proc_set>:

void sys_cont_proc_set(void){
80107115:	55                   	push   %ebp
80107116:	89 e5                	mov    %esp,%ebp
80107118:	53                   	push   %ebx
80107119:	83 ec 24             	sub    $0x24,%esp

  int vc_num;
  argint(0, &vc_num);
8010711c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010711f:	89 44 24 04          	mov    %eax,0x4(%esp)
80107123:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010712a:	e8 2e ec ff ff       	call   80105d5d <argint>

  // cprintf("before getting container\n");

  //So I can get the name, but I can't get the corresponding container
  // cprintf("In sys call proc set, container name is %s.\n", get_container(vc_num)->name);
  myproc()->cont = get_container(vc_num);
8010712f:	e8 73 d4 ff ff       	call   801045a7 <myproc>
80107134:	89 c3                	mov    %eax,%ebx
80107136:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107139:	89 04 24             	mov    %eax,(%esp)
8010713c:	e8 1a 25 00 00       	call   8010965b <get_container>
80107141:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  // cprintf("MY proc container name = %s.\n", myproc()->cont->name);

  // cprintf("after getting container\n");
}
80107147:	83 c4 24             	add    $0x24,%esp
8010714a:	5b                   	pop    %ebx
8010714b:	5d                   	pop    %ebp
8010714c:	c3                   	ret    

8010714d <sys_set_max_mem>:

void sys_set_max_mem(void){
8010714d:	55                   	push   %ebp
8010714e:	89 e5                	mov    %esp,%ebp
80107150:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
80107153:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107156:	89 44 24 04          	mov    %eax,0x4(%esp)
8010715a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107161:	e8 f7 eb ff ff       	call   80105d5d <argint>

  int vc_num;
  argint(1, &vc_num);
80107166:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107169:	89 44 24 04          	mov    %eax,0x4(%esp)
8010716d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80107174:	e8 e4 eb ff ff       	call   80105d5d <argint>

  set_max_mem(mem, vc_num);
80107179:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010717c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010717f:	89 54 24 04          	mov    %edx,0x4(%esp)
80107183:	89 04 24             	mov    %eax,(%esp)
80107186:	e8 37 26 00 00       	call   801097c2 <set_max_mem>
}
8010718b:	c9                   	leave  
8010718c:	c3                   	ret    

8010718d <sys_set_os>:
void sys_set_os(void){
8010718d:	55                   	push   %ebp
8010718e:	89 e5                	mov    %esp,%ebp
80107190:	83 ec 28             	sub    $0x28,%esp
  int os;
  argint(0, &os);
80107193:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107196:	89 44 24 04          	mov    %eax,0x4(%esp)
8010719a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801071a1:	e8 b7 eb ff ff       	call   80105d5d <argint>
  set_os(os);
801071a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071a9:	89 04 24             	mov    %eax,(%esp)
801071ac:	e8 2e 26 00 00       	call   801097df <set_os>
}
801071b1:	c9                   	leave  
801071b2:	c3                   	ret    

801071b3 <sys_set_max_disk>:

void sys_set_max_disk(void){
801071b3:	55                   	push   %ebp
801071b4:	89 e5                	mov    %esp,%ebp
801071b6:	83 ec 28             	sub    $0x28,%esp
  int disk;
  argint(0, &disk);
801071b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801071bc:	89 44 24 04          	mov    %eax,0x4(%esp)
801071c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801071c7:	e8 91 eb ff ff       	call   80105d5d <argint>

  int vc_num;
  argint(1, &vc_num);
801071cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801071cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801071d3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801071da:	e8 7e eb ff ff       	call   80105d5d <argint>

  set_max_disk(disk, vc_num);
801071df:	8b 55 f0             	mov    -0x10(%ebp),%edx
801071e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071e5:	89 54 24 04          	mov    %edx,0x4(%esp)
801071e9:	89 04 24             	mov    %eax,(%esp)
801071ec:	e8 03 26 00 00       	call   801097f4 <set_max_disk>
}
801071f1:	c9                   	leave  
801071f2:	c3                   	ret    

801071f3 <sys_set_max_proc>:

void sys_set_max_proc(void){
801071f3:	55                   	push   %ebp
801071f4:	89 e5                	mov    %esp,%ebp
801071f6:	83 ec 28             	sub    $0x28,%esp
  int proc;
  argint(0, &proc);
801071f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801071fc:	89 44 24 04          	mov    %eax,0x4(%esp)
80107200:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107207:	e8 51 eb ff ff       	call   80105d5d <argint>

  int vc_num;
  argint(1, &vc_num);
8010720c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010720f:	89 44 24 04          	mov    %eax,0x4(%esp)
80107213:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010721a:	e8 3e eb ff ff       	call   80105d5d <argint>

  set_max_proc(proc, vc_num);
8010721f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107222:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107225:	89 54 24 04          	mov    %edx,0x4(%esp)
80107229:	89 04 24             	mov    %eax,(%esp)
8010722c:	e8 e1 25 00 00       	call   80109812 <set_max_proc>
}
80107231:	c9                   	leave  
80107232:	c3                   	ret    

80107233 <sys_set_curr_mem>:

void sys_set_curr_mem(void){
80107233:	55                   	push   %ebp
80107234:	89 e5                	mov    %esp,%ebp
80107236:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
80107239:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010723c:	89 44 24 04          	mov    %eax,0x4(%esp)
80107240:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107247:	e8 11 eb ff ff       	call   80105d5d <argint>

  int vc_num;
  argint(1, &vc_num);
8010724c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010724f:	89 44 24 04          	mov    %eax,0x4(%esp)
80107253:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010725a:	e8 fe ea ff ff       	call   80105d5d <argint>

  set_curr_mem(mem, vc_num);
8010725f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107262:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107265:	89 54 24 04          	mov    %edx,0x4(%esp)
80107269:	89 04 24             	mov    %eax,(%esp)
8010726c:	e8 bf 25 00 00       	call   80109830 <set_curr_mem>
}
80107271:	c9                   	leave  
80107272:	c3                   	ret    

80107273 <sys_reduce_curr_mem>:

void sys_reduce_curr_mem(void){
80107273:	55                   	push   %ebp
80107274:	89 e5                	mov    %esp,%ebp
80107276:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
80107279:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010727c:	89 44 24 04          	mov    %eax,0x4(%esp)
80107280:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107287:	e8 d1 ea ff ff       	call   80105d5d <argint>

  int vc_num;
  argint(1, &vc_num);
8010728c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010728f:	89 44 24 04          	mov    %eax,0x4(%esp)
80107293:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010729a:	e8 be ea ff ff       	call   80105d5d <argint>

  set_curr_mem(mem, vc_num);
8010729f:	8b 55 f0             	mov    -0x10(%ebp),%edx
801072a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072a5:	89 54 24 04          	mov    %edx,0x4(%esp)
801072a9:	89 04 24             	mov    %eax,(%esp)
801072ac:	e8 7f 25 00 00       	call   80109830 <set_curr_mem>
}
801072b1:	c9                   	leave  
801072b2:	c3                   	ret    

801072b3 <sys_set_curr_disk>:

void sys_set_curr_disk(void){
801072b3:	55                   	push   %ebp
801072b4:	89 e5                	mov    %esp,%ebp
801072b6:	83 ec 28             	sub    $0x28,%esp
  int disk;
  argint(0, &disk);
801072b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801072bc:	89 44 24 04          	mov    %eax,0x4(%esp)
801072c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801072c7:	e8 91 ea ff ff       	call   80105d5d <argint>

  int vc_num;
  argint(1, &vc_num);
801072cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801072cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801072d3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801072da:	e8 7e ea ff ff       	call   80105d5d <argint>

  set_curr_disk(disk, vc_num);
801072df:	8b 55 f0             	mov    -0x10(%ebp),%edx
801072e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072e5:	89 54 24 04          	mov    %edx,0x4(%esp)
801072e9:	89 04 24             	mov    %eax,(%esp)
801072ec:	e8 e4 25 00 00       	call   801098d5 <set_curr_disk>
}
801072f1:	c9                   	leave  
801072f2:	c3                   	ret    

801072f3 <sys_set_curr_proc>:

void sys_set_curr_proc(void){
801072f3:	55                   	push   %ebp
801072f4:	89 e5                	mov    %esp,%ebp
801072f6:	83 ec 28             	sub    $0x28,%esp
  int proc;
  argint(0, &proc);
801072f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801072fc:	89 44 24 04          	mov    %eax,0x4(%esp)
80107300:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107307:	e8 51 ea ff ff       	call   80105d5d <argint>

  int vc_num;
  argint(1, &vc_num);
8010730c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010730f:	89 44 24 04          	mov    %eax,0x4(%esp)
80107313:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010731a:	e8 3e ea ff ff       	call   80105d5d <argint>

  set_curr_proc(proc, vc_num);
8010731f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107322:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107325:	89 54 24 04          	mov    %edx,0x4(%esp)
80107329:	89 04 24             	mov    %eax,(%esp)
8010732c:	e8 2a 26 00 00       	call   8010995b <set_curr_proc>
}
80107331:	c9                   	leave  
80107332:	c3                   	ret    

80107333 <sys_container_reset>:

void sys_container_reset(void){
80107333:	55                   	push   %ebp
80107334:	89 e5                	mov    %esp,%ebp
80107336:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(1, &vc_num);
80107339:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010733c:	89 44 24 04          	mov    %eax,0x4(%esp)
80107340:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80107347:	e8 11 ea ff ff       	call   80105d5d <argint>
  container_reset(vc_num);
8010734c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010734f:	89 04 24             	mov    %eax,(%esp)
80107352:	e8 a1 28 00 00       	call   80109bf8 <container_reset>
}
80107357:	c9                   	leave  
80107358:	c3                   	ret    

80107359 <sys_uptime>:
// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80107359:	55                   	push   %ebp
8010735a:	89 e5                	mov    %esp,%ebp
8010735c:	83 ec 28             	sub    $0x28,%esp
  uint xticks;

  acquire(&tickslock);
8010735f:	c7 04 24 00 85 11 80 	movl   $0x80118500,(%esp)
80107366:	e8 5c e4 ff ff       	call   801057c7 <acquire>
  xticks = ticks;
8010736b:	a1 40 8d 11 80       	mov    0x80118d40,%eax
80107370:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80107373:	c7 04 24 00 85 11 80 	movl   $0x80118500,(%esp)
8010737a:	e8 b2 e4 ff ff       	call   80105831 <release>
  return xticks;
8010737f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107382:	c9                   	leave  
80107383:	c3                   	ret    

80107384 <sys_getticks>:

int
sys_getticks(void){
80107384:	55                   	push   %ebp
80107385:	89 e5                	mov    %esp,%ebp
80107387:	83 ec 08             	sub    $0x8,%esp
  return myproc()->ticks;
8010738a:	e8 18 d2 ff ff       	call   801045a7 <myproc>
8010738f:	8b 40 7c             	mov    0x7c(%eax),%eax
}
80107392:	c9                   	leave  
80107393:	c3                   	ret    

80107394 <sys_max_containers>:

int sys_max_containers(void){
80107394:	55                   	push   %ebp
80107395:	89 e5                	mov    %esp,%ebp
80107397:	83 ec 08             	sub    $0x8,%esp
  return max_containers();
8010739a:	e8 31 26 00 00       	call   801099d0 <max_containers>
}
8010739f:	c9                   	leave  
801073a0:	c3                   	ret    

801073a1 <sys_df>:


void sys_df(void){
801073a1:	55                   	push   %ebp
801073a2:	89 e5                	mov    %esp,%ebp
801073a4:	83 ec 58             	sub    $0x58,%esp
  struct container* cont = myproc()->cont;
801073a7:	e8 fb d1 ff ff       	call   801045a7 <myproc>
801073ac:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801073b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct superblock sb;
  readsb(1, &sb);
801073b5:	8d 45 b8             	lea    -0x48(%ebp),%eax
801073b8:	89 44 24 04          	mov    %eax,0x4(%esp)
801073bc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801073c3:	e8 f8 a0 ff ff       	call   801014c0 <readsb>

  int used = 0;
801073c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  if(cont == NULL){
801073cf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801073d3:	75 6c                	jne    80107441 <sys_df+0xa0>
    int max = max_containers();
801073d5:	e8 f6 25 00 00       	call   801099d0 <max_containers>
801073da:	89 45 e8             	mov    %eax,-0x18(%ebp)
    int i;
    for(i = 0; i < max; i++){
801073dd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801073e4:	eb 37                	jmp    8010741d <sys_df+0x7c>
      used = used + (int)(get_curr_disk(i) / 1024);
801073e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801073e9:	89 04 24             	mov    %eax,(%esp)
801073ec:	e8 6a 23 00 00       	call   8010975b <get_curr_disk>
801073f1:	85 c0                	test   %eax,%eax
801073f3:	79 05                	jns    801073fa <sys_df+0x59>
801073f5:	05 ff 03 00 00       	add    $0x3ff,%eax
801073fa:	c1 f8 0a             	sar    $0xa,%eax
801073fd:	01 45 f4             	add    %eax,-0xc(%ebp)
      if(i == 0){
80107400:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107404:	75 14                	jne    8010741a <sys_df+0x79>
        used += (int)(get_os() / 1024);
80107406:	e8 46 22 00 00       	call   80109651 <get_os>
8010740b:	85 c0                	test   %eax,%eax
8010740d:	79 05                	jns    80107414 <sys_df+0x73>
8010740f:	05 ff 03 00 00       	add    $0x3ff,%eax
80107414:	c1 f8 0a             	sar    $0xa,%eax
80107417:	01 45 f4             	add    %eax,-0xc(%ebp)

  int used = 0;
  if(cont == NULL){
    int max = max_containers();
    int i;
    for(i = 0; i < max; i++){
8010741a:	ff 45 f0             	incl   -0x10(%ebp)
8010741d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107420:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80107423:	7c c1                	jl     801073e6 <sys_df+0x45>
      used = used + (int)(get_curr_disk(i) / 1024);
      if(i == 0){
        used += (int)(get_os() / 1024);
      }
    }
    cprintf("~%d used out of %d available.\n", used, sb.nblocks);
80107425:	8b 45 bc             	mov    -0x44(%ebp),%eax
80107428:	89 44 24 08          	mov    %eax,0x8(%esp)
8010742c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010742f:	89 44 24 04          	mov    %eax,0x4(%esp)
80107433:	c7 04 24 64 a3 10 80 	movl   $0x8010a364,(%esp)
8010743a:	e8 82 8f ff ff       	call   801003c1 <cprintf>
8010743f:	eb 4d                	jmp    8010748e <sys_df+0xed>
  }
  else{
    int x = find(cont->name);
80107441:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107444:	83 c0 1c             	add    $0x1c,%eax
80107447:	89 04 24             	mov    %eax,(%esp)
8010744a:	e8 62 21 00 00       	call   801095b1 <find>
8010744f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    int used = (int)(get_curr_disk(x) / 1024);
80107452:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107455:	89 04 24             	mov    %eax,(%esp)
80107458:	e8 fe 22 00 00       	call   8010975b <get_curr_disk>
8010745d:	85 c0                	test   %eax,%eax
8010745f:	79 05                	jns    80107466 <sys_df+0xc5>
80107461:	05 ff 03 00 00       	add    $0x3ff,%eax
80107466:	c1 f8 0a             	sar    $0xa,%eax
80107469:	89 45 e0             	mov    %eax,-0x20(%ebp)
    cprintf("~%d used out of %d available.\n", used,  get_max_disk(x));
8010746c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010746f:	89 04 24             	mov    %eax,(%esp)
80107472:	e8 3c 22 00 00       	call   801096b3 <get_max_disk>
80107477:	89 44 24 08          	mov    %eax,0x8(%esp)
8010747b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010747e:	89 44 24 04          	mov    %eax,0x4(%esp)
80107482:	c7 04 24 64 a3 10 80 	movl   $0x8010a364,(%esp)
80107489:	e8 33 8f ff ff       	call   801003c1 <cprintf>
  }
}
8010748e:	c9                   	leave  
8010748f:	c3                   	ret    

80107490 <sys_pause>:

void
sys_pause(void){
80107490:	55                   	push   %ebp
80107491:	89 e5                	mov    %esp,%ebp
80107493:	83 ec 28             	sub    $0x28,%esp
  char *name;
  argstr(0, &name);
80107496:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107499:	89 44 24 04          	mov    %eax,0x4(%esp)
8010749d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801074a4:	e8 4b e9 ff ff       	call   80105df4 <argstr>
  pause(name);
801074a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074ac:	89 04 24             	mov    %eax,(%esp)
801074af:	e8 e4 e0 ff ff       	call   80105598 <pause>
}
801074b4:	c9                   	leave  
801074b5:	c3                   	ret    

801074b6 <sys_resume>:

void
sys_resume(void){
801074b6:	55                   	push   %ebp
801074b7:	89 e5                	mov    %esp,%ebp
801074b9:	83 ec 28             	sub    $0x28,%esp
  char *name;
  argstr(0, &name);
801074bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
801074bf:	89 44 24 04          	mov    %eax,0x4(%esp)
801074c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801074ca:	e8 25 e9 ff ff       	call   80105df4 <argstr>
  resume(name);
801074cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074d2:	89 04 24             	mov    %eax,(%esp)
801074d5:	e8 21 e1 ff ff       	call   801055fb <resume>
}
801074da:	c9                   	leave  
801074db:	c3                   	ret    

801074dc <sys_tmem>:

int
sys_tmem(void){
801074dc:	55                   	push   %ebp
801074dd:	89 e5                	mov    %esp,%ebp
801074df:	83 ec 28             	sub    $0x28,%esp
  struct container* cont = myproc()->cont;
801074e2:	e8 c0 d0 ff ff       	call   801045a7 <myproc>
801074e7:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801074ed:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(cont == NULL){
801074f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801074f4:	75 07                	jne    801074fd <sys_tmem+0x21>
    return mem_usage();
801074f6:	e8 fc ba ff ff       	call   80102ff7 <mem_usage>
801074fb:	eb 16                	jmp    80107513 <sys_tmem+0x37>
  }
  return get_curr_mem(find(cont->name));
801074fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107500:	83 c0 1c             	add    $0x1c,%eax
80107503:	89 04 24             	mov    %eax,(%esp)
80107506:	e8 a6 20 00 00       	call   801095b1 <find>
8010750b:	89 04 24             	mov    %eax,(%esp)
8010750e:	e8 10 22 00 00       	call   80109723 <get_curr_mem>
}
80107513:	c9                   	leave  
80107514:	c3                   	ret    

80107515 <sys_amem>:

int
sys_amem(void){
80107515:	55                   	push   %ebp
80107516:	89 e5                	mov    %esp,%ebp
80107518:	83 ec 28             	sub    $0x28,%esp
  struct container* cont = myproc()->cont;
8010751b:	e8 87 d0 ff ff       	call   801045a7 <myproc>
80107520:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80107526:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(cont == NULL){
80107529:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010752d:	75 07                	jne    80107536 <sys_amem+0x21>
    return mem_avail();
8010752f:	e8 cd ba ff ff       	call   80103001 <mem_avail>
80107534:	eb 16                	jmp    8010754c <sys_amem+0x37>
  }
  return get_max_mem(find(cont->name));
80107536:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107539:	83 c0 1c             	add    $0x1c,%eax
8010753c:	89 04 24             	mov    %eax,(%esp)
8010753f:	e8 6d 20 00 00       	call   801095b1 <find>
80107544:	89 04 24             	mov    %eax,(%esp)
80107547:	e8 2f 21 00 00       	call   8010967b <get_max_mem>
}
8010754c:	c9                   	leave  
8010754d:	c3                   	ret    

8010754e <sys_c_ps>:

void sys_c_ps(void){
8010754e:	55                   	push   %ebp
8010754f:	89 e5                	mov    %esp,%ebp
80107551:	83 ec 28             	sub    $0x28,%esp
  char *name;
  argstr(0, &name);
80107554:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107557:	89 44 24 04          	mov    %eax,0x4(%esp)
8010755b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107562:	e8 8d e8 ff ff       	call   80105df4 <argstr>
  c_proc_data(name);
80107567:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010756a:	89 04 24             	mov    %eax,(%esp)
8010756d:	e8 67 de ff ff       	call   801053d9 <c_proc_data>
  // c_procdump(name);
}
80107572:	c9                   	leave  
80107573:	c3                   	ret    

80107574 <sys_get_used>:

int sys_get_used(void){
80107574:	55                   	push   %ebp
80107575:	89 e5                	mov    %esp,%ebp
80107577:	83 ec 28             	sub    $0x28,%esp
  int x; 
  argint(0, &x);
8010757a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010757d:	89 44 24 04          	mov    %eax,0x4(%esp)
80107581:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107588:	e8 d0 e7 ff ff       	call   80105d5d <argint>
  return get_used(x);
8010758d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107590:	89 04 24             	mov    %eax,(%esp)
80107593:	e8 5f 1f 00 00       	call   801094f7 <get_used>
}
80107598:	c9                   	leave  
80107599:	c3                   	ret    

8010759a <sys_get_cticks>:

int sys_get_cticks(void){
8010759a:	55                   	push   %ebp
8010759b:	89 e5                	mov    %esp,%ebp
8010759d:	83 ec 08             	sub    $0x8,%esp
  return get_cticks();
801075a0:	e8 95 24 00 00       	call   80109a3a <get_cticks>
}
801075a5:	c9                   	leave  
801075a6:	c3                   	ret    

801075a7 <sys_tick_reset2>:

void sys_tick_reset2(void){
801075a7:	55                   	push   %ebp
801075a8:	89 e5                	mov    %esp,%ebp
801075aa:	83 ec 08             	sub    $0x8,%esp
  tick_reset2();
801075ad:	e8 14 26 00 00       	call   80109bc6 <tick_reset2>
}
801075b2:	c9                   	leave  
801075b3:	c3                   	ret    

801075b4 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801075b4:	1e                   	push   %ds
  pushl %es
801075b5:	06                   	push   %es
  pushl %fs
801075b6:	0f a0                	push   %fs
  pushl %gs
801075b8:	0f a8                	push   %gs
  pushal
801075ba:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801075bb:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801075bf:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801075c1:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801075c3:	54                   	push   %esp
  call trap
801075c4:	e8 c0 01 00 00       	call   80107789 <trap>
  addl $4, %esp
801075c9:	83 c4 04             	add    $0x4,%esp

801075cc <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801075cc:	61                   	popa   
  popl %gs
801075cd:	0f a9                	pop    %gs
  popl %fs
801075cf:	0f a1                	pop    %fs
  popl %es
801075d1:	07                   	pop    %es
  popl %ds
801075d2:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801075d3:	83 c4 08             	add    $0x8,%esp
  iret
801075d6:	cf                   	iret   
	...

801075d8 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801075d8:	55                   	push   %ebp
801075d9:	89 e5                	mov    %esp,%ebp
801075db:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801075de:	8b 45 0c             	mov    0xc(%ebp),%eax
801075e1:	48                   	dec    %eax
801075e2:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801075e6:	8b 45 08             	mov    0x8(%ebp),%eax
801075e9:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801075ed:	8b 45 08             	mov    0x8(%ebp),%eax
801075f0:	c1 e8 10             	shr    $0x10,%eax
801075f3:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801075f7:	8d 45 fa             	lea    -0x6(%ebp),%eax
801075fa:	0f 01 18             	lidtl  (%eax)
}
801075fd:	c9                   	leave  
801075fe:	c3                   	ret    

801075ff <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801075ff:	55                   	push   %ebp
80107600:	89 e5                	mov    %esp,%ebp
80107602:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80107605:	0f 20 d0             	mov    %cr2,%eax
80107608:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
8010760b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010760e:	c9                   	leave  
8010760f:	c3                   	ret    

80107610 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80107610:	55                   	push   %ebp
80107611:	89 e5                	mov    %esp,%ebp
80107613:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80107616:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010761d:	e9 b8 00 00 00       	jmp    801076da <tvinit+0xca>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80107622:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107625:	8b 04 85 48 d1 10 80 	mov    -0x7fef2eb8(,%eax,4),%eax
8010762c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010762f:	66 89 04 d5 40 85 11 	mov    %ax,-0x7fee7ac0(,%edx,8)
80107636:	80 
80107637:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010763a:	66 c7 04 c5 42 85 11 	movw   $0x8,-0x7fee7abe(,%eax,8)
80107641:	80 08 00 
80107644:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107647:	8a 14 c5 44 85 11 80 	mov    -0x7fee7abc(,%eax,8),%dl
8010764e:	83 e2 e0             	and    $0xffffffe0,%edx
80107651:	88 14 c5 44 85 11 80 	mov    %dl,-0x7fee7abc(,%eax,8)
80107658:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010765b:	8a 14 c5 44 85 11 80 	mov    -0x7fee7abc(,%eax,8),%dl
80107662:	83 e2 1f             	and    $0x1f,%edx
80107665:	88 14 c5 44 85 11 80 	mov    %dl,-0x7fee7abc(,%eax,8)
8010766c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010766f:	8a 14 c5 45 85 11 80 	mov    -0x7fee7abb(,%eax,8),%dl
80107676:	83 e2 f0             	and    $0xfffffff0,%edx
80107679:	83 ca 0e             	or     $0xe,%edx
8010767c:	88 14 c5 45 85 11 80 	mov    %dl,-0x7fee7abb(,%eax,8)
80107683:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107686:	8a 14 c5 45 85 11 80 	mov    -0x7fee7abb(,%eax,8),%dl
8010768d:	83 e2 ef             	and    $0xffffffef,%edx
80107690:	88 14 c5 45 85 11 80 	mov    %dl,-0x7fee7abb(,%eax,8)
80107697:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010769a:	8a 14 c5 45 85 11 80 	mov    -0x7fee7abb(,%eax,8),%dl
801076a1:	83 e2 9f             	and    $0xffffff9f,%edx
801076a4:	88 14 c5 45 85 11 80 	mov    %dl,-0x7fee7abb(,%eax,8)
801076ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076ae:	8a 14 c5 45 85 11 80 	mov    -0x7fee7abb(,%eax,8),%dl
801076b5:	83 ca 80             	or     $0xffffff80,%edx
801076b8:	88 14 c5 45 85 11 80 	mov    %dl,-0x7fee7abb(,%eax,8)
801076bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076c2:	8b 04 85 48 d1 10 80 	mov    -0x7fef2eb8(,%eax,4),%eax
801076c9:	c1 e8 10             	shr    $0x10,%eax
801076cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801076cf:	66 89 04 d5 46 85 11 	mov    %ax,-0x7fee7aba(,%edx,8)
801076d6:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801076d7:	ff 45 f4             	incl   -0xc(%ebp)
801076da:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801076e1:	0f 8e 3b ff ff ff    	jle    80107622 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801076e7:	a1 48 d2 10 80       	mov    0x8010d248,%eax
801076ec:	66 a3 40 87 11 80    	mov    %ax,0x80118740
801076f2:	66 c7 05 42 87 11 80 	movw   $0x8,0x80118742
801076f9:	08 00 
801076fb:	a0 44 87 11 80       	mov    0x80118744,%al
80107700:	83 e0 e0             	and    $0xffffffe0,%eax
80107703:	a2 44 87 11 80       	mov    %al,0x80118744
80107708:	a0 44 87 11 80       	mov    0x80118744,%al
8010770d:	83 e0 1f             	and    $0x1f,%eax
80107710:	a2 44 87 11 80       	mov    %al,0x80118744
80107715:	a0 45 87 11 80       	mov    0x80118745,%al
8010771a:	83 c8 0f             	or     $0xf,%eax
8010771d:	a2 45 87 11 80       	mov    %al,0x80118745
80107722:	a0 45 87 11 80       	mov    0x80118745,%al
80107727:	83 e0 ef             	and    $0xffffffef,%eax
8010772a:	a2 45 87 11 80       	mov    %al,0x80118745
8010772f:	a0 45 87 11 80       	mov    0x80118745,%al
80107734:	83 c8 60             	or     $0x60,%eax
80107737:	a2 45 87 11 80       	mov    %al,0x80118745
8010773c:	a0 45 87 11 80       	mov    0x80118745,%al
80107741:	83 c8 80             	or     $0xffffff80,%eax
80107744:	a2 45 87 11 80       	mov    %al,0x80118745
80107749:	a1 48 d2 10 80       	mov    0x8010d248,%eax
8010774e:	c1 e8 10             	shr    $0x10,%eax
80107751:	66 a3 46 87 11 80    	mov    %ax,0x80118746

  initlock(&tickslock, "time");
80107757:	c7 44 24 04 84 a3 10 	movl   $0x8010a384,0x4(%esp)
8010775e:	80 
8010775f:	c7 04 24 00 85 11 80 	movl   $0x80118500,(%esp)
80107766:	e8 3b e0 ff ff       	call   801057a6 <initlock>
}
8010776b:	c9                   	leave  
8010776c:	c3                   	ret    

8010776d <idtinit>:

void
idtinit(void)
{
8010776d:	55                   	push   %ebp
8010776e:	89 e5                	mov    %esp,%ebp
80107770:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80107773:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
8010777a:	00 
8010777b:	c7 04 24 40 85 11 80 	movl   $0x80118540,(%esp)
80107782:	e8 51 fe ff ff       	call   801075d8 <lidt>
}
80107787:	c9                   	leave  
80107788:	c3                   	ret    

80107789 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80107789:	55                   	push   %ebp
8010778a:	89 e5                	mov    %esp,%ebp
8010778c:	57                   	push   %edi
8010778d:	56                   	push   %esi
8010778e:	53                   	push   %ebx
8010778f:	83 ec 4c             	sub    $0x4c,%esp
  struct proc *p;
  if(tf->trapno == T_SYSCALL){
80107792:	8b 45 08             	mov    0x8(%ebp),%eax
80107795:	8b 40 30             	mov    0x30(%eax),%eax
80107798:	83 f8 40             	cmp    $0x40,%eax
8010779b:	75 3c                	jne    801077d9 <trap+0x50>
    if(myproc()->killed)
8010779d:	e8 05 ce ff ff       	call   801045a7 <myproc>
801077a2:	8b 40 24             	mov    0x24(%eax),%eax
801077a5:	85 c0                	test   %eax,%eax
801077a7:	74 05                	je     801077ae <trap+0x25>
      exit();
801077a9:	e8 8a d2 ff ff       	call   80104a38 <exit>
    myproc()->tf = tf;
801077ae:	e8 f4 cd ff ff       	call   801045a7 <myproc>
801077b3:	8b 55 08             	mov    0x8(%ebp),%edx
801077b6:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801077b9:	e8 6d e6 ff ff       	call   80105e2b <syscall>
    if(myproc()->killed)
801077be:	e8 e4 cd ff ff       	call   801045a7 <myproc>
801077c3:	8b 40 24             	mov    0x24(%eax),%eax
801077c6:	85 c0                	test   %eax,%eax
801077c8:	74 0a                	je     801077d4 <trap+0x4b>
      exit();
801077ca:	e8 69 d2 ff ff       	call   80104a38 <exit>
    return;
801077cf:	e9 40 02 00 00       	jmp    80107a14 <trap+0x28b>
801077d4:	e9 3b 02 00 00       	jmp    80107a14 <trap+0x28b>
  }

  switch(tf->trapno){
801077d9:	8b 45 08             	mov    0x8(%ebp),%eax
801077dc:	8b 40 30             	mov    0x30(%eax),%eax
801077df:	83 e8 20             	sub    $0x20,%eax
801077e2:	83 f8 1f             	cmp    $0x1f,%eax
801077e5:	0f 87 db 00 00 00    	ja     801078c6 <trap+0x13d>
801077eb:	8b 04 85 2c a4 10 80 	mov    -0x7fef5bd4(,%eax,4),%eax
801077f2:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801077f4:	e8 e5 cc ff ff       	call   801044de <cpuid>
801077f9:	85 c0                	test   %eax,%eax
801077fb:	75 2f                	jne    8010782c <trap+0xa3>
      acquire(&tickslock);
801077fd:	c7 04 24 00 85 11 80 	movl   $0x80118500,(%esp)
80107804:	e8 be df ff ff       	call   801057c7 <acquire>
      ticks++;
80107809:	a1 40 8d 11 80       	mov    0x80118d40,%eax
8010780e:	40                   	inc    %eax
8010780f:	a3 40 8d 11 80       	mov    %eax,0x80118d40
      wakeup(&ticks);
80107814:	c7 04 24 40 8d 11 80 	movl   $0x80118d40,(%esp)
8010781b:	e8 7e d7 ff ff       	call   80104f9e <wakeup>
      release(&tickslock);
80107820:	c7 04 24 00 85 11 80 	movl   $0x80118500,(%esp)
80107827:	e8 05 e0 ff ff       	call   80105831 <release>
    }
    p = myproc();
8010782c:	e8 76 cd ff ff       	call   801045a7 <myproc>
80107831:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (p != 0) {
80107834:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80107838:	74 1f                	je     80107859 <trap+0xd0>
      p->ticks++;
8010783a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010783d:	8b 40 7c             	mov    0x7c(%eax),%eax
80107840:	8d 50 01             	lea    0x1(%eax),%edx
80107843:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107846:	89 50 7c             	mov    %edx,0x7c(%eax)
      p->cont->ticks++;
80107849:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010784c:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80107852:	8b 50 40             	mov    0x40(%eax),%edx
80107855:	42                   	inc    %edx
80107856:	89 50 40             	mov    %edx,0x40(%eax)
    }
    lapiceoi();
80107859:	e8 21 bb ff ff       	call   8010337f <lapiceoi>
    break;
8010785e:	e9 35 01 00 00       	jmp    80107998 <trap+0x20f>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80107863:	e8 66 b2 ff ff       	call   80102ace <ideintr>
    lapiceoi();
80107868:	e8 12 bb ff ff       	call   8010337f <lapiceoi>
    break;
8010786d:	e9 26 01 00 00       	jmp    80107998 <trap+0x20f>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80107872:	e8 1f b9 ff ff       	call   80103196 <kbdintr>
    lapiceoi();
80107877:	e8 03 bb ff ff       	call   8010337f <lapiceoi>
    break;
8010787c:	e9 17 01 00 00       	jmp    80107998 <trap+0x20f>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80107881:	e8 6f 03 00 00       	call   80107bf5 <uartintr>
    lapiceoi();
80107886:	e8 f4 ba ff ff       	call   8010337f <lapiceoi>
    break;
8010788b:	e9 08 01 00 00       	jmp    80107998 <trap+0x20f>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107890:	8b 45 08             	mov    0x8(%ebp),%eax
80107893:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80107896:	8b 45 08             	mov    0x8(%ebp),%eax
80107899:	8b 40 3c             	mov    0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010789c:	0f b7 d8             	movzwl %ax,%ebx
8010789f:	e8 3a cc ff ff       	call   801044de <cpuid>
801078a4:	89 74 24 0c          	mov    %esi,0xc(%esp)
801078a8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801078ac:	89 44 24 04          	mov    %eax,0x4(%esp)
801078b0:	c7 04 24 8c a3 10 80 	movl   $0x8010a38c,(%esp)
801078b7:	e8 05 8b ff ff       	call   801003c1 <cprintf>
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
801078bc:	e8 be ba ff ff       	call   8010337f <lapiceoi>
    break;
801078c1:	e9 d2 00 00 00       	jmp    80107998 <trap+0x20f>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
801078c6:	e8 dc cc ff ff       	call   801045a7 <myproc>
801078cb:	85 c0                	test   %eax,%eax
801078cd:	74 10                	je     801078df <trap+0x156>
801078cf:	8b 45 08             	mov    0x8(%ebp),%eax
801078d2:	8b 40 3c             	mov    0x3c(%eax),%eax
801078d5:	0f b7 c0             	movzwl %ax,%eax
801078d8:	83 e0 03             	and    $0x3,%eax
801078db:	85 c0                	test   %eax,%eax
801078dd:	75 40                	jne    8010791f <trap+0x196>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801078df:	e8 1b fd ff ff       	call   801075ff <rcr2>
801078e4:	89 c3                	mov    %eax,%ebx
801078e6:	8b 45 08             	mov    0x8(%ebp),%eax
801078e9:	8b 70 38             	mov    0x38(%eax),%esi
801078ec:	e8 ed cb ff ff       	call   801044de <cpuid>
801078f1:	8b 55 08             	mov    0x8(%ebp),%edx
801078f4:	8b 52 30             	mov    0x30(%edx),%edx
801078f7:	89 5c 24 10          	mov    %ebx,0x10(%esp)
801078fb:	89 74 24 0c          	mov    %esi,0xc(%esp)
801078ff:	89 44 24 08          	mov    %eax,0x8(%esp)
80107903:	89 54 24 04          	mov    %edx,0x4(%esp)
80107907:	c7 04 24 b0 a3 10 80 	movl   $0x8010a3b0,(%esp)
8010790e:	e8 ae 8a ff ff       	call   801003c1 <cprintf>
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80107913:	c7 04 24 e2 a3 10 80 	movl   $0x8010a3e2,(%esp)
8010791a:	e8 35 8c ff ff       	call   80100554 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010791f:	e8 db fc ff ff       	call   801075ff <rcr2>
80107924:	89 c6                	mov    %eax,%esi
80107926:	8b 45 08             	mov    0x8(%ebp),%eax
80107929:	8b 40 38             	mov    0x38(%eax),%eax
8010792c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
8010792f:	e8 aa cb ff ff       	call   801044de <cpuid>
80107934:	89 c3                	mov    %eax,%ebx
80107936:	8b 45 08             	mov    0x8(%ebp),%eax
80107939:	8b 78 34             	mov    0x34(%eax),%edi
8010793c:	89 7d d0             	mov    %edi,-0x30(%ebp)
8010793f:	8b 45 08             	mov    0x8(%ebp),%eax
80107942:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80107945:	e8 5d cc ff ff       	call   801045a7 <myproc>
8010794a:	8d 50 6c             	lea    0x6c(%eax),%edx
8010794d:	89 55 cc             	mov    %edx,-0x34(%ebp)
80107950:	e8 52 cc ff ff       	call   801045a7 <myproc>
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107955:	8b 40 10             	mov    0x10(%eax),%eax
80107958:	89 74 24 1c          	mov    %esi,0x1c(%esp)
8010795c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
8010795f:	89 4c 24 18          	mov    %ecx,0x18(%esp)
80107963:	89 5c 24 14          	mov    %ebx,0x14(%esp)
80107967:	8b 4d d0             	mov    -0x30(%ebp),%ecx
8010796a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
8010796e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
80107972:	8b 55 cc             	mov    -0x34(%ebp),%edx
80107975:	89 54 24 08          	mov    %edx,0x8(%esp)
80107979:	89 44 24 04          	mov    %eax,0x4(%esp)
8010797d:	c7 04 24 e8 a3 10 80 	movl   $0x8010a3e8,(%esp)
80107984:	e8 38 8a ff ff       	call   801003c1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80107989:	e8 19 cc ff ff       	call   801045a7 <myproc>
8010798e:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80107995:	eb 01                	jmp    80107998 <trap+0x20f>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80107997:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80107998:	e8 0a cc ff ff       	call   801045a7 <myproc>
8010799d:	85 c0                	test   %eax,%eax
8010799f:	74 22                	je     801079c3 <trap+0x23a>
801079a1:	e8 01 cc ff ff       	call   801045a7 <myproc>
801079a6:	8b 40 24             	mov    0x24(%eax),%eax
801079a9:	85 c0                	test   %eax,%eax
801079ab:	74 16                	je     801079c3 <trap+0x23a>
801079ad:	8b 45 08             	mov    0x8(%ebp),%eax
801079b0:	8b 40 3c             	mov    0x3c(%eax),%eax
801079b3:	0f b7 c0             	movzwl %ax,%eax
801079b6:	83 e0 03             	and    $0x3,%eax
801079b9:	83 f8 03             	cmp    $0x3,%eax
801079bc:	75 05                	jne    801079c3 <trap+0x23a>
    exit();
801079be:	e8 75 d0 ff ff       	call   80104a38 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801079c3:	e8 df cb ff ff       	call   801045a7 <myproc>
801079c8:	85 c0                	test   %eax,%eax
801079ca:	74 1d                	je     801079e9 <trap+0x260>
801079cc:	e8 d6 cb ff ff       	call   801045a7 <myproc>
801079d1:	8b 40 0c             	mov    0xc(%eax),%eax
801079d4:	83 f8 04             	cmp    $0x4,%eax
801079d7:	75 10                	jne    801079e9 <trap+0x260>
     tf->trapno == T_IRQ0+IRQ_TIMER)
801079d9:	8b 45 08             	mov    0x8(%ebp),%eax
801079dc:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801079df:	83 f8 20             	cmp    $0x20,%eax
801079e2:	75 05                	jne    801079e9 <trap+0x260>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();
801079e4:	e8 6e d4 ff ff       	call   80104e57 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801079e9:	e8 b9 cb ff ff       	call   801045a7 <myproc>
801079ee:	85 c0                	test   %eax,%eax
801079f0:	74 22                	je     80107a14 <trap+0x28b>
801079f2:	e8 b0 cb ff ff       	call   801045a7 <myproc>
801079f7:	8b 40 24             	mov    0x24(%eax),%eax
801079fa:	85 c0                	test   %eax,%eax
801079fc:	74 16                	je     80107a14 <trap+0x28b>
801079fe:	8b 45 08             	mov    0x8(%ebp),%eax
80107a01:	8b 40 3c             	mov    0x3c(%eax),%eax
80107a04:	0f b7 c0             	movzwl %ax,%eax
80107a07:	83 e0 03             	and    $0x3,%eax
80107a0a:	83 f8 03             	cmp    $0x3,%eax
80107a0d:	75 05                	jne    80107a14 <trap+0x28b>
    exit();
80107a0f:	e8 24 d0 ff ff       	call   80104a38 <exit>
}
80107a14:	83 c4 4c             	add    $0x4c,%esp
80107a17:	5b                   	pop    %ebx
80107a18:	5e                   	pop    %esi
80107a19:	5f                   	pop    %edi
80107a1a:	5d                   	pop    %ebp
80107a1b:	c3                   	ret    

80107a1c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80107a1c:	55                   	push   %ebp
80107a1d:	89 e5                	mov    %esp,%ebp
80107a1f:	83 ec 14             	sub    $0x14,%esp
80107a22:	8b 45 08             	mov    0x8(%ebp),%eax
80107a25:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107a29:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107a2c:	89 c2                	mov    %eax,%edx
80107a2e:	ec                   	in     (%dx),%al
80107a2f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107a32:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80107a35:	c9                   	leave  
80107a36:	c3                   	ret    

80107a37 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107a37:	55                   	push   %ebp
80107a38:	89 e5                	mov    %esp,%ebp
80107a3a:	83 ec 08             	sub    $0x8,%esp
80107a3d:	8b 45 08             	mov    0x8(%ebp),%eax
80107a40:	8b 55 0c             	mov    0xc(%ebp),%edx
80107a43:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80107a47:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107a4a:	8a 45 f8             	mov    -0x8(%ebp),%al
80107a4d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80107a50:	ee                   	out    %al,(%dx)
}
80107a51:	c9                   	leave  
80107a52:	c3                   	ret    

80107a53 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80107a53:	55                   	push   %ebp
80107a54:	89 e5                	mov    %esp,%ebp
80107a56:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80107a59:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107a60:	00 
80107a61:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80107a68:	e8 ca ff ff ff       	call   80107a37 <outb>

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107a6d:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80107a74:	00 
80107a75:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80107a7c:	e8 b6 ff ff ff       	call   80107a37 <outb>
  outb(COM1+0, 115200/9600);
80107a81:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80107a88:	00 
80107a89:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107a90:	e8 a2 ff ff ff       	call   80107a37 <outb>
  outb(COM1+1, 0);
80107a95:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107a9c:	00 
80107a9d:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107aa4:	e8 8e ff ff ff       	call   80107a37 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107aa9:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80107ab0:	00 
80107ab1:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80107ab8:	e8 7a ff ff ff       	call   80107a37 <outb>
  outb(COM1+4, 0);
80107abd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107ac4:	00 
80107ac5:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80107acc:	e8 66 ff ff ff       	call   80107a37 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107ad1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80107ad8:	00 
80107ad9:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107ae0:	e8 52 ff ff ff       	call   80107a37 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107ae5:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107aec:	e8 2b ff ff ff       	call   80107a1c <inb>
80107af1:	3c ff                	cmp    $0xff,%al
80107af3:	75 02                	jne    80107af7 <uartinit+0xa4>
    return;
80107af5:	eb 5b                	jmp    80107b52 <uartinit+0xff>
  uart = 1;
80107af7:	c7 05 64 d9 10 80 01 	movl   $0x1,0x8010d964
80107afe:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107b01:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80107b08:	e8 0f ff ff ff       	call   80107a1c <inb>
  inb(COM1+0);
80107b0d:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107b14:	e8 03 ff ff ff       	call   80107a1c <inb>
  ioapicenable(IRQ_COM1, 0);
80107b19:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107b20:	00 
80107b21:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80107b28:	e8 16 b2 ff ff       	call   80102d43 <ioapicenable>

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107b2d:	c7 45 f4 ac a4 10 80 	movl   $0x8010a4ac,-0xc(%ebp)
80107b34:	eb 13                	jmp    80107b49 <uartinit+0xf6>
    uartputc(*p);
80107b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b39:	8a 00                	mov    (%eax),%al
80107b3b:	0f be c0             	movsbl %al,%eax
80107b3e:	89 04 24             	mov    %eax,(%esp)
80107b41:	e8 0e 00 00 00       	call   80107b54 <uartputc>
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107b46:	ff 45 f4             	incl   -0xc(%ebp)
80107b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4c:	8a 00                	mov    (%eax),%al
80107b4e:	84 c0                	test   %al,%al
80107b50:	75 e4                	jne    80107b36 <uartinit+0xe3>
    uartputc(*p);
}
80107b52:	c9                   	leave  
80107b53:	c3                   	ret    

80107b54 <uartputc>:

void
uartputc(int c)
{
80107b54:	55                   	push   %ebp
80107b55:	89 e5                	mov    %esp,%ebp
80107b57:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80107b5a:	a1 64 d9 10 80       	mov    0x8010d964,%eax
80107b5f:	85 c0                	test   %eax,%eax
80107b61:	75 02                	jne    80107b65 <uartputc+0x11>
    return;
80107b63:	eb 4a                	jmp    80107baf <uartputc+0x5b>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107b65:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107b6c:	eb 0f                	jmp    80107b7d <uartputc+0x29>
    microdelay(10);
80107b6e:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80107b75:	e8 2a b8 ff ff       	call   801033a4 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107b7a:	ff 45 f4             	incl   -0xc(%ebp)
80107b7d:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107b81:	7f 16                	jg     80107b99 <uartputc+0x45>
80107b83:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107b8a:	e8 8d fe ff ff       	call   80107a1c <inb>
80107b8f:	0f b6 c0             	movzbl %al,%eax
80107b92:	83 e0 20             	and    $0x20,%eax
80107b95:	85 c0                	test   %eax,%eax
80107b97:	74 d5                	je     80107b6e <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80107b99:	8b 45 08             	mov    0x8(%ebp),%eax
80107b9c:	0f b6 c0             	movzbl %al,%eax
80107b9f:	89 44 24 04          	mov    %eax,0x4(%esp)
80107ba3:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107baa:	e8 88 fe ff ff       	call   80107a37 <outb>
}
80107baf:	c9                   	leave  
80107bb0:	c3                   	ret    

80107bb1 <uartgetc>:

static int
uartgetc(void)
{
80107bb1:	55                   	push   %ebp
80107bb2:	89 e5                	mov    %esp,%ebp
80107bb4:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80107bb7:	a1 64 d9 10 80       	mov    0x8010d964,%eax
80107bbc:	85 c0                	test   %eax,%eax
80107bbe:	75 07                	jne    80107bc7 <uartgetc+0x16>
    return -1;
80107bc0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107bc5:	eb 2c                	jmp    80107bf3 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80107bc7:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107bce:	e8 49 fe ff ff       	call   80107a1c <inb>
80107bd3:	0f b6 c0             	movzbl %al,%eax
80107bd6:	83 e0 01             	and    $0x1,%eax
80107bd9:	85 c0                	test   %eax,%eax
80107bdb:	75 07                	jne    80107be4 <uartgetc+0x33>
    return -1;
80107bdd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107be2:	eb 0f                	jmp    80107bf3 <uartgetc+0x42>
  return inb(COM1+0);
80107be4:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107beb:	e8 2c fe ff ff       	call   80107a1c <inb>
80107bf0:	0f b6 c0             	movzbl %al,%eax
}
80107bf3:	c9                   	leave  
80107bf4:	c3                   	ret    

80107bf5 <uartintr>:

void
uartintr(void)
{
80107bf5:	55                   	push   %ebp
80107bf6:	89 e5                	mov    %esp,%ebp
80107bf8:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80107bfb:	c7 04 24 b1 7b 10 80 	movl   $0x80107bb1,(%esp)
80107c02:	e8 ee 8b ff ff       	call   801007f5 <consoleintr>
}
80107c07:	c9                   	leave  
80107c08:	c3                   	ret    
80107c09:	00 00                	add    %al,(%eax)
	...

80107c0c <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107c0c:	6a 00                	push   $0x0
  pushl $0
80107c0e:	6a 00                	push   $0x0
  jmp alltraps
80107c10:	e9 9f f9 ff ff       	jmp    801075b4 <alltraps>

80107c15 <vector1>:
.globl vector1
vector1:
  pushl $0
80107c15:	6a 00                	push   $0x0
  pushl $1
80107c17:	6a 01                	push   $0x1
  jmp alltraps
80107c19:	e9 96 f9 ff ff       	jmp    801075b4 <alltraps>

80107c1e <vector2>:
.globl vector2
vector2:
  pushl $0
80107c1e:	6a 00                	push   $0x0
  pushl $2
80107c20:	6a 02                	push   $0x2
  jmp alltraps
80107c22:	e9 8d f9 ff ff       	jmp    801075b4 <alltraps>

80107c27 <vector3>:
.globl vector3
vector3:
  pushl $0
80107c27:	6a 00                	push   $0x0
  pushl $3
80107c29:	6a 03                	push   $0x3
  jmp alltraps
80107c2b:	e9 84 f9 ff ff       	jmp    801075b4 <alltraps>

80107c30 <vector4>:
.globl vector4
vector4:
  pushl $0
80107c30:	6a 00                	push   $0x0
  pushl $4
80107c32:	6a 04                	push   $0x4
  jmp alltraps
80107c34:	e9 7b f9 ff ff       	jmp    801075b4 <alltraps>

80107c39 <vector5>:
.globl vector5
vector5:
  pushl $0
80107c39:	6a 00                	push   $0x0
  pushl $5
80107c3b:	6a 05                	push   $0x5
  jmp alltraps
80107c3d:	e9 72 f9 ff ff       	jmp    801075b4 <alltraps>

80107c42 <vector6>:
.globl vector6
vector6:
  pushl $0
80107c42:	6a 00                	push   $0x0
  pushl $6
80107c44:	6a 06                	push   $0x6
  jmp alltraps
80107c46:	e9 69 f9 ff ff       	jmp    801075b4 <alltraps>

80107c4b <vector7>:
.globl vector7
vector7:
  pushl $0
80107c4b:	6a 00                	push   $0x0
  pushl $7
80107c4d:	6a 07                	push   $0x7
  jmp alltraps
80107c4f:	e9 60 f9 ff ff       	jmp    801075b4 <alltraps>

80107c54 <vector8>:
.globl vector8
vector8:
  pushl $8
80107c54:	6a 08                	push   $0x8
  jmp alltraps
80107c56:	e9 59 f9 ff ff       	jmp    801075b4 <alltraps>

80107c5b <vector9>:
.globl vector9
vector9:
  pushl $0
80107c5b:	6a 00                	push   $0x0
  pushl $9
80107c5d:	6a 09                	push   $0x9
  jmp alltraps
80107c5f:	e9 50 f9 ff ff       	jmp    801075b4 <alltraps>

80107c64 <vector10>:
.globl vector10
vector10:
  pushl $10
80107c64:	6a 0a                	push   $0xa
  jmp alltraps
80107c66:	e9 49 f9 ff ff       	jmp    801075b4 <alltraps>

80107c6b <vector11>:
.globl vector11
vector11:
  pushl $11
80107c6b:	6a 0b                	push   $0xb
  jmp alltraps
80107c6d:	e9 42 f9 ff ff       	jmp    801075b4 <alltraps>

80107c72 <vector12>:
.globl vector12
vector12:
  pushl $12
80107c72:	6a 0c                	push   $0xc
  jmp alltraps
80107c74:	e9 3b f9 ff ff       	jmp    801075b4 <alltraps>

80107c79 <vector13>:
.globl vector13
vector13:
  pushl $13
80107c79:	6a 0d                	push   $0xd
  jmp alltraps
80107c7b:	e9 34 f9 ff ff       	jmp    801075b4 <alltraps>

80107c80 <vector14>:
.globl vector14
vector14:
  pushl $14
80107c80:	6a 0e                	push   $0xe
  jmp alltraps
80107c82:	e9 2d f9 ff ff       	jmp    801075b4 <alltraps>

80107c87 <vector15>:
.globl vector15
vector15:
  pushl $0
80107c87:	6a 00                	push   $0x0
  pushl $15
80107c89:	6a 0f                	push   $0xf
  jmp alltraps
80107c8b:	e9 24 f9 ff ff       	jmp    801075b4 <alltraps>

80107c90 <vector16>:
.globl vector16
vector16:
  pushl $0
80107c90:	6a 00                	push   $0x0
  pushl $16
80107c92:	6a 10                	push   $0x10
  jmp alltraps
80107c94:	e9 1b f9 ff ff       	jmp    801075b4 <alltraps>

80107c99 <vector17>:
.globl vector17
vector17:
  pushl $17
80107c99:	6a 11                	push   $0x11
  jmp alltraps
80107c9b:	e9 14 f9 ff ff       	jmp    801075b4 <alltraps>

80107ca0 <vector18>:
.globl vector18
vector18:
  pushl $0
80107ca0:	6a 00                	push   $0x0
  pushl $18
80107ca2:	6a 12                	push   $0x12
  jmp alltraps
80107ca4:	e9 0b f9 ff ff       	jmp    801075b4 <alltraps>

80107ca9 <vector19>:
.globl vector19
vector19:
  pushl $0
80107ca9:	6a 00                	push   $0x0
  pushl $19
80107cab:	6a 13                	push   $0x13
  jmp alltraps
80107cad:	e9 02 f9 ff ff       	jmp    801075b4 <alltraps>

80107cb2 <vector20>:
.globl vector20
vector20:
  pushl $0
80107cb2:	6a 00                	push   $0x0
  pushl $20
80107cb4:	6a 14                	push   $0x14
  jmp alltraps
80107cb6:	e9 f9 f8 ff ff       	jmp    801075b4 <alltraps>

80107cbb <vector21>:
.globl vector21
vector21:
  pushl $0
80107cbb:	6a 00                	push   $0x0
  pushl $21
80107cbd:	6a 15                	push   $0x15
  jmp alltraps
80107cbf:	e9 f0 f8 ff ff       	jmp    801075b4 <alltraps>

80107cc4 <vector22>:
.globl vector22
vector22:
  pushl $0
80107cc4:	6a 00                	push   $0x0
  pushl $22
80107cc6:	6a 16                	push   $0x16
  jmp alltraps
80107cc8:	e9 e7 f8 ff ff       	jmp    801075b4 <alltraps>

80107ccd <vector23>:
.globl vector23
vector23:
  pushl $0
80107ccd:	6a 00                	push   $0x0
  pushl $23
80107ccf:	6a 17                	push   $0x17
  jmp alltraps
80107cd1:	e9 de f8 ff ff       	jmp    801075b4 <alltraps>

80107cd6 <vector24>:
.globl vector24
vector24:
  pushl $0
80107cd6:	6a 00                	push   $0x0
  pushl $24
80107cd8:	6a 18                	push   $0x18
  jmp alltraps
80107cda:	e9 d5 f8 ff ff       	jmp    801075b4 <alltraps>

80107cdf <vector25>:
.globl vector25
vector25:
  pushl $0
80107cdf:	6a 00                	push   $0x0
  pushl $25
80107ce1:	6a 19                	push   $0x19
  jmp alltraps
80107ce3:	e9 cc f8 ff ff       	jmp    801075b4 <alltraps>

80107ce8 <vector26>:
.globl vector26
vector26:
  pushl $0
80107ce8:	6a 00                	push   $0x0
  pushl $26
80107cea:	6a 1a                	push   $0x1a
  jmp alltraps
80107cec:	e9 c3 f8 ff ff       	jmp    801075b4 <alltraps>

80107cf1 <vector27>:
.globl vector27
vector27:
  pushl $0
80107cf1:	6a 00                	push   $0x0
  pushl $27
80107cf3:	6a 1b                	push   $0x1b
  jmp alltraps
80107cf5:	e9 ba f8 ff ff       	jmp    801075b4 <alltraps>

80107cfa <vector28>:
.globl vector28
vector28:
  pushl $0
80107cfa:	6a 00                	push   $0x0
  pushl $28
80107cfc:	6a 1c                	push   $0x1c
  jmp alltraps
80107cfe:	e9 b1 f8 ff ff       	jmp    801075b4 <alltraps>

80107d03 <vector29>:
.globl vector29
vector29:
  pushl $0
80107d03:	6a 00                	push   $0x0
  pushl $29
80107d05:	6a 1d                	push   $0x1d
  jmp alltraps
80107d07:	e9 a8 f8 ff ff       	jmp    801075b4 <alltraps>

80107d0c <vector30>:
.globl vector30
vector30:
  pushl $0
80107d0c:	6a 00                	push   $0x0
  pushl $30
80107d0e:	6a 1e                	push   $0x1e
  jmp alltraps
80107d10:	e9 9f f8 ff ff       	jmp    801075b4 <alltraps>

80107d15 <vector31>:
.globl vector31
vector31:
  pushl $0
80107d15:	6a 00                	push   $0x0
  pushl $31
80107d17:	6a 1f                	push   $0x1f
  jmp alltraps
80107d19:	e9 96 f8 ff ff       	jmp    801075b4 <alltraps>

80107d1e <vector32>:
.globl vector32
vector32:
  pushl $0
80107d1e:	6a 00                	push   $0x0
  pushl $32
80107d20:	6a 20                	push   $0x20
  jmp alltraps
80107d22:	e9 8d f8 ff ff       	jmp    801075b4 <alltraps>

80107d27 <vector33>:
.globl vector33
vector33:
  pushl $0
80107d27:	6a 00                	push   $0x0
  pushl $33
80107d29:	6a 21                	push   $0x21
  jmp alltraps
80107d2b:	e9 84 f8 ff ff       	jmp    801075b4 <alltraps>

80107d30 <vector34>:
.globl vector34
vector34:
  pushl $0
80107d30:	6a 00                	push   $0x0
  pushl $34
80107d32:	6a 22                	push   $0x22
  jmp alltraps
80107d34:	e9 7b f8 ff ff       	jmp    801075b4 <alltraps>

80107d39 <vector35>:
.globl vector35
vector35:
  pushl $0
80107d39:	6a 00                	push   $0x0
  pushl $35
80107d3b:	6a 23                	push   $0x23
  jmp alltraps
80107d3d:	e9 72 f8 ff ff       	jmp    801075b4 <alltraps>

80107d42 <vector36>:
.globl vector36
vector36:
  pushl $0
80107d42:	6a 00                	push   $0x0
  pushl $36
80107d44:	6a 24                	push   $0x24
  jmp alltraps
80107d46:	e9 69 f8 ff ff       	jmp    801075b4 <alltraps>

80107d4b <vector37>:
.globl vector37
vector37:
  pushl $0
80107d4b:	6a 00                	push   $0x0
  pushl $37
80107d4d:	6a 25                	push   $0x25
  jmp alltraps
80107d4f:	e9 60 f8 ff ff       	jmp    801075b4 <alltraps>

80107d54 <vector38>:
.globl vector38
vector38:
  pushl $0
80107d54:	6a 00                	push   $0x0
  pushl $38
80107d56:	6a 26                	push   $0x26
  jmp alltraps
80107d58:	e9 57 f8 ff ff       	jmp    801075b4 <alltraps>

80107d5d <vector39>:
.globl vector39
vector39:
  pushl $0
80107d5d:	6a 00                	push   $0x0
  pushl $39
80107d5f:	6a 27                	push   $0x27
  jmp alltraps
80107d61:	e9 4e f8 ff ff       	jmp    801075b4 <alltraps>

80107d66 <vector40>:
.globl vector40
vector40:
  pushl $0
80107d66:	6a 00                	push   $0x0
  pushl $40
80107d68:	6a 28                	push   $0x28
  jmp alltraps
80107d6a:	e9 45 f8 ff ff       	jmp    801075b4 <alltraps>

80107d6f <vector41>:
.globl vector41
vector41:
  pushl $0
80107d6f:	6a 00                	push   $0x0
  pushl $41
80107d71:	6a 29                	push   $0x29
  jmp alltraps
80107d73:	e9 3c f8 ff ff       	jmp    801075b4 <alltraps>

80107d78 <vector42>:
.globl vector42
vector42:
  pushl $0
80107d78:	6a 00                	push   $0x0
  pushl $42
80107d7a:	6a 2a                	push   $0x2a
  jmp alltraps
80107d7c:	e9 33 f8 ff ff       	jmp    801075b4 <alltraps>

80107d81 <vector43>:
.globl vector43
vector43:
  pushl $0
80107d81:	6a 00                	push   $0x0
  pushl $43
80107d83:	6a 2b                	push   $0x2b
  jmp alltraps
80107d85:	e9 2a f8 ff ff       	jmp    801075b4 <alltraps>

80107d8a <vector44>:
.globl vector44
vector44:
  pushl $0
80107d8a:	6a 00                	push   $0x0
  pushl $44
80107d8c:	6a 2c                	push   $0x2c
  jmp alltraps
80107d8e:	e9 21 f8 ff ff       	jmp    801075b4 <alltraps>

80107d93 <vector45>:
.globl vector45
vector45:
  pushl $0
80107d93:	6a 00                	push   $0x0
  pushl $45
80107d95:	6a 2d                	push   $0x2d
  jmp alltraps
80107d97:	e9 18 f8 ff ff       	jmp    801075b4 <alltraps>

80107d9c <vector46>:
.globl vector46
vector46:
  pushl $0
80107d9c:	6a 00                	push   $0x0
  pushl $46
80107d9e:	6a 2e                	push   $0x2e
  jmp alltraps
80107da0:	e9 0f f8 ff ff       	jmp    801075b4 <alltraps>

80107da5 <vector47>:
.globl vector47
vector47:
  pushl $0
80107da5:	6a 00                	push   $0x0
  pushl $47
80107da7:	6a 2f                	push   $0x2f
  jmp alltraps
80107da9:	e9 06 f8 ff ff       	jmp    801075b4 <alltraps>

80107dae <vector48>:
.globl vector48
vector48:
  pushl $0
80107dae:	6a 00                	push   $0x0
  pushl $48
80107db0:	6a 30                	push   $0x30
  jmp alltraps
80107db2:	e9 fd f7 ff ff       	jmp    801075b4 <alltraps>

80107db7 <vector49>:
.globl vector49
vector49:
  pushl $0
80107db7:	6a 00                	push   $0x0
  pushl $49
80107db9:	6a 31                	push   $0x31
  jmp alltraps
80107dbb:	e9 f4 f7 ff ff       	jmp    801075b4 <alltraps>

80107dc0 <vector50>:
.globl vector50
vector50:
  pushl $0
80107dc0:	6a 00                	push   $0x0
  pushl $50
80107dc2:	6a 32                	push   $0x32
  jmp alltraps
80107dc4:	e9 eb f7 ff ff       	jmp    801075b4 <alltraps>

80107dc9 <vector51>:
.globl vector51
vector51:
  pushl $0
80107dc9:	6a 00                	push   $0x0
  pushl $51
80107dcb:	6a 33                	push   $0x33
  jmp alltraps
80107dcd:	e9 e2 f7 ff ff       	jmp    801075b4 <alltraps>

80107dd2 <vector52>:
.globl vector52
vector52:
  pushl $0
80107dd2:	6a 00                	push   $0x0
  pushl $52
80107dd4:	6a 34                	push   $0x34
  jmp alltraps
80107dd6:	e9 d9 f7 ff ff       	jmp    801075b4 <alltraps>

80107ddb <vector53>:
.globl vector53
vector53:
  pushl $0
80107ddb:	6a 00                	push   $0x0
  pushl $53
80107ddd:	6a 35                	push   $0x35
  jmp alltraps
80107ddf:	e9 d0 f7 ff ff       	jmp    801075b4 <alltraps>

80107de4 <vector54>:
.globl vector54
vector54:
  pushl $0
80107de4:	6a 00                	push   $0x0
  pushl $54
80107de6:	6a 36                	push   $0x36
  jmp alltraps
80107de8:	e9 c7 f7 ff ff       	jmp    801075b4 <alltraps>

80107ded <vector55>:
.globl vector55
vector55:
  pushl $0
80107ded:	6a 00                	push   $0x0
  pushl $55
80107def:	6a 37                	push   $0x37
  jmp alltraps
80107df1:	e9 be f7 ff ff       	jmp    801075b4 <alltraps>

80107df6 <vector56>:
.globl vector56
vector56:
  pushl $0
80107df6:	6a 00                	push   $0x0
  pushl $56
80107df8:	6a 38                	push   $0x38
  jmp alltraps
80107dfa:	e9 b5 f7 ff ff       	jmp    801075b4 <alltraps>

80107dff <vector57>:
.globl vector57
vector57:
  pushl $0
80107dff:	6a 00                	push   $0x0
  pushl $57
80107e01:	6a 39                	push   $0x39
  jmp alltraps
80107e03:	e9 ac f7 ff ff       	jmp    801075b4 <alltraps>

80107e08 <vector58>:
.globl vector58
vector58:
  pushl $0
80107e08:	6a 00                	push   $0x0
  pushl $58
80107e0a:	6a 3a                	push   $0x3a
  jmp alltraps
80107e0c:	e9 a3 f7 ff ff       	jmp    801075b4 <alltraps>

80107e11 <vector59>:
.globl vector59
vector59:
  pushl $0
80107e11:	6a 00                	push   $0x0
  pushl $59
80107e13:	6a 3b                	push   $0x3b
  jmp alltraps
80107e15:	e9 9a f7 ff ff       	jmp    801075b4 <alltraps>

80107e1a <vector60>:
.globl vector60
vector60:
  pushl $0
80107e1a:	6a 00                	push   $0x0
  pushl $60
80107e1c:	6a 3c                	push   $0x3c
  jmp alltraps
80107e1e:	e9 91 f7 ff ff       	jmp    801075b4 <alltraps>

80107e23 <vector61>:
.globl vector61
vector61:
  pushl $0
80107e23:	6a 00                	push   $0x0
  pushl $61
80107e25:	6a 3d                	push   $0x3d
  jmp alltraps
80107e27:	e9 88 f7 ff ff       	jmp    801075b4 <alltraps>

80107e2c <vector62>:
.globl vector62
vector62:
  pushl $0
80107e2c:	6a 00                	push   $0x0
  pushl $62
80107e2e:	6a 3e                	push   $0x3e
  jmp alltraps
80107e30:	e9 7f f7 ff ff       	jmp    801075b4 <alltraps>

80107e35 <vector63>:
.globl vector63
vector63:
  pushl $0
80107e35:	6a 00                	push   $0x0
  pushl $63
80107e37:	6a 3f                	push   $0x3f
  jmp alltraps
80107e39:	e9 76 f7 ff ff       	jmp    801075b4 <alltraps>

80107e3e <vector64>:
.globl vector64
vector64:
  pushl $0
80107e3e:	6a 00                	push   $0x0
  pushl $64
80107e40:	6a 40                	push   $0x40
  jmp alltraps
80107e42:	e9 6d f7 ff ff       	jmp    801075b4 <alltraps>

80107e47 <vector65>:
.globl vector65
vector65:
  pushl $0
80107e47:	6a 00                	push   $0x0
  pushl $65
80107e49:	6a 41                	push   $0x41
  jmp alltraps
80107e4b:	e9 64 f7 ff ff       	jmp    801075b4 <alltraps>

80107e50 <vector66>:
.globl vector66
vector66:
  pushl $0
80107e50:	6a 00                	push   $0x0
  pushl $66
80107e52:	6a 42                	push   $0x42
  jmp alltraps
80107e54:	e9 5b f7 ff ff       	jmp    801075b4 <alltraps>

80107e59 <vector67>:
.globl vector67
vector67:
  pushl $0
80107e59:	6a 00                	push   $0x0
  pushl $67
80107e5b:	6a 43                	push   $0x43
  jmp alltraps
80107e5d:	e9 52 f7 ff ff       	jmp    801075b4 <alltraps>

80107e62 <vector68>:
.globl vector68
vector68:
  pushl $0
80107e62:	6a 00                	push   $0x0
  pushl $68
80107e64:	6a 44                	push   $0x44
  jmp alltraps
80107e66:	e9 49 f7 ff ff       	jmp    801075b4 <alltraps>

80107e6b <vector69>:
.globl vector69
vector69:
  pushl $0
80107e6b:	6a 00                	push   $0x0
  pushl $69
80107e6d:	6a 45                	push   $0x45
  jmp alltraps
80107e6f:	e9 40 f7 ff ff       	jmp    801075b4 <alltraps>

80107e74 <vector70>:
.globl vector70
vector70:
  pushl $0
80107e74:	6a 00                	push   $0x0
  pushl $70
80107e76:	6a 46                	push   $0x46
  jmp alltraps
80107e78:	e9 37 f7 ff ff       	jmp    801075b4 <alltraps>

80107e7d <vector71>:
.globl vector71
vector71:
  pushl $0
80107e7d:	6a 00                	push   $0x0
  pushl $71
80107e7f:	6a 47                	push   $0x47
  jmp alltraps
80107e81:	e9 2e f7 ff ff       	jmp    801075b4 <alltraps>

80107e86 <vector72>:
.globl vector72
vector72:
  pushl $0
80107e86:	6a 00                	push   $0x0
  pushl $72
80107e88:	6a 48                	push   $0x48
  jmp alltraps
80107e8a:	e9 25 f7 ff ff       	jmp    801075b4 <alltraps>

80107e8f <vector73>:
.globl vector73
vector73:
  pushl $0
80107e8f:	6a 00                	push   $0x0
  pushl $73
80107e91:	6a 49                	push   $0x49
  jmp alltraps
80107e93:	e9 1c f7 ff ff       	jmp    801075b4 <alltraps>

80107e98 <vector74>:
.globl vector74
vector74:
  pushl $0
80107e98:	6a 00                	push   $0x0
  pushl $74
80107e9a:	6a 4a                	push   $0x4a
  jmp alltraps
80107e9c:	e9 13 f7 ff ff       	jmp    801075b4 <alltraps>

80107ea1 <vector75>:
.globl vector75
vector75:
  pushl $0
80107ea1:	6a 00                	push   $0x0
  pushl $75
80107ea3:	6a 4b                	push   $0x4b
  jmp alltraps
80107ea5:	e9 0a f7 ff ff       	jmp    801075b4 <alltraps>

80107eaa <vector76>:
.globl vector76
vector76:
  pushl $0
80107eaa:	6a 00                	push   $0x0
  pushl $76
80107eac:	6a 4c                	push   $0x4c
  jmp alltraps
80107eae:	e9 01 f7 ff ff       	jmp    801075b4 <alltraps>

80107eb3 <vector77>:
.globl vector77
vector77:
  pushl $0
80107eb3:	6a 00                	push   $0x0
  pushl $77
80107eb5:	6a 4d                	push   $0x4d
  jmp alltraps
80107eb7:	e9 f8 f6 ff ff       	jmp    801075b4 <alltraps>

80107ebc <vector78>:
.globl vector78
vector78:
  pushl $0
80107ebc:	6a 00                	push   $0x0
  pushl $78
80107ebe:	6a 4e                	push   $0x4e
  jmp alltraps
80107ec0:	e9 ef f6 ff ff       	jmp    801075b4 <alltraps>

80107ec5 <vector79>:
.globl vector79
vector79:
  pushl $0
80107ec5:	6a 00                	push   $0x0
  pushl $79
80107ec7:	6a 4f                	push   $0x4f
  jmp alltraps
80107ec9:	e9 e6 f6 ff ff       	jmp    801075b4 <alltraps>

80107ece <vector80>:
.globl vector80
vector80:
  pushl $0
80107ece:	6a 00                	push   $0x0
  pushl $80
80107ed0:	6a 50                	push   $0x50
  jmp alltraps
80107ed2:	e9 dd f6 ff ff       	jmp    801075b4 <alltraps>

80107ed7 <vector81>:
.globl vector81
vector81:
  pushl $0
80107ed7:	6a 00                	push   $0x0
  pushl $81
80107ed9:	6a 51                	push   $0x51
  jmp alltraps
80107edb:	e9 d4 f6 ff ff       	jmp    801075b4 <alltraps>

80107ee0 <vector82>:
.globl vector82
vector82:
  pushl $0
80107ee0:	6a 00                	push   $0x0
  pushl $82
80107ee2:	6a 52                	push   $0x52
  jmp alltraps
80107ee4:	e9 cb f6 ff ff       	jmp    801075b4 <alltraps>

80107ee9 <vector83>:
.globl vector83
vector83:
  pushl $0
80107ee9:	6a 00                	push   $0x0
  pushl $83
80107eeb:	6a 53                	push   $0x53
  jmp alltraps
80107eed:	e9 c2 f6 ff ff       	jmp    801075b4 <alltraps>

80107ef2 <vector84>:
.globl vector84
vector84:
  pushl $0
80107ef2:	6a 00                	push   $0x0
  pushl $84
80107ef4:	6a 54                	push   $0x54
  jmp alltraps
80107ef6:	e9 b9 f6 ff ff       	jmp    801075b4 <alltraps>

80107efb <vector85>:
.globl vector85
vector85:
  pushl $0
80107efb:	6a 00                	push   $0x0
  pushl $85
80107efd:	6a 55                	push   $0x55
  jmp alltraps
80107eff:	e9 b0 f6 ff ff       	jmp    801075b4 <alltraps>

80107f04 <vector86>:
.globl vector86
vector86:
  pushl $0
80107f04:	6a 00                	push   $0x0
  pushl $86
80107f06:	6a 56                	push   $0x56
  jmp alltraps
80107f08:	e9 a7 f6 ff ff       	jmp    801075b4 <alltraps>

80107f0d <vector87>:
.globl vector87
vector87:
  pushl $0
80107f0d:	6a 00                	push   $0x0
  pushl $87
80107f0f:	6a 57                	push   $0x57
  jmp alltraps
80107f11:	e9 9e f6 ff ff       	jmp    801075b4 <alltraps>

80107f16 <vector88>:
.globl vector88
vector88:
  pushl $0
80107f16:	6a 00                	push   $0x0
  pushl $88
80107f18:	6a 58                	push   $0x58
  jmp alltraps
80107f1a:	e9 95 f6 ff ff       	jmp    801075b4 <alltraps>

80107f1f <vector89>:
.globl vector89
vector89:
  pushl $0
80107f1f:	6a 00                	push   $0x0
  pushl $89
80107f21:	6a 59                	push   $0x59
  jmp alltraps
80107f23:	e9 8c f6 ff ff       	jmp    801075b4 <alltraps>

80107f28 <vector90>:
.globl vector90
vector90:
  pushl $0
80107f28:	6a 00                	push   $0x0
  pushl $90
80107f2a:	6a 5a                	push   $0x5a
  jmp alltraps
80107f2c:	e9 83 f6 ff ff       	jmp    801075b4 <alltraps>

80107f31 <vector91>:
.globl vector91
vector91:
  pushl $0
80107f31:	6a 00                	push   $0x0
  pushl $91
80107f33:	6a 5b                	push   $0x5b
  jmp alltraps
80107f35:	e9 7a f6 ff ff       	jmp    801075b4 <alltraps>

80107f3a <vector92>:
.globl vector92
vector92:
  pushl $0
80107f3a:	6a 00                	push   $0x0
  pushl $92
80107f3c:	6a 5c                	push   $0x5c
  jmp alltraps
80107f3e:	e9 71 f6 ff ff       	jmp    801075b4 <alltraps>

80107f43 <vector93>:
.globl vector93
vector93:
  pushl $0
80107f43:	6a 00                	push   $0x0
  pushl $93
80107f45:	6a 5d                	push   $0x5d
  jmp alltraps
80107f47:	e9 68 f6 ff ff       	jmp    801075b4 <alltraps>

80107f4c <vector94>:
.globl vector94
vector94:
  pushl $0
80107f4c:	6a 00                	push   $0x0
  pushl $94
80107f4e:	6a 5e                	push   $0x5e
  jmp alltraps
80107f50:	e9 5f f6 ff ff       	jmp    801075b4 <alltraps>

80107f55 <vector95>:
.globl vector95
vector95:
  pushl $0
80107f55:	6a 00                	push   $0x0
  pushl $95
80107f57:	6a 5f                	push   $0x5f
  jmp alltraps
80107f59:	e9 56 f6 ff ff       	jmp    801075b4 <alltraps>

80107f5e <vector96>:
.globl vector96
vector96:
  pushl $0
80107f5e:	6a 00                	push   $0x0
  pushl $96
80107f60:	6a 60                	push   $0x60
  jmp alltraps
80107f62:	e9 4d f6 ff ff       	jmp    801075b4 <alltraps>

80107f67 <vector97>:
.globl vector97
vector97:
  pushl $0
80107f67:	6a 00                	push   $0x0
  pushl $97
80107f69:	6a 61                	push   $0x61
  jmp alltraps
80107f6b:	e9 44 f6 ff ff       	jmp    801075b4 <alltraps>

80107f70 <vector98>:
.globl vector98
vector98:
  pushl $0
80107f70:	6a 00                	push   $0x0
  pushl $98
80107f72:	6a 62                	push   $0x62
  jmp alltraps
80107f74:	e9 3b f6 ff ff       	jmp    801075b4 <alltraps>

80107f79 <vector99>:
.globl vector99
vector99:
  pushl $0
80107f79:	6a 00                	push   $0x0
  pushl $99
80107f7b:	6a 63                	push   $0x63
  jmp alltraps
80107f7d:	e9 32 f6 ff ff       	jmp    801075b4 <alltraps>

80107f82 <vector100>:
.globl vector100
vector100:
  pushl $0
80107f82:	6a 00                	push   $0x0
  pushl $100
80107f84:	6a 64                	push   $0x64
  jmp alltraps
80107f86:	e9 29 f6 ff ff       	jmp    801075b4 <alltraps>

80107f8b <vector101>:
.globl vector101
vector101:
  pushl $0
80107f8b:	6a 00                	push   $0x0
  pushl $101
80107f8d:	6a 65                	push   $0x65
  jmp alltraps
80107f8f:	e9 20 f6 ff ff       	jmp    801075b4 <alltraps>

80107f94 <vector102>:
.globl vector102
vector102:
  pushl $0
80107f94:	6a 00                	push   $0x0
  pushl $102
80107f96:	6a 66                	push   $0x66
  jmp alltraps
80107f98:	e9 17 f6 ff ff       	jmp    801075b4 <alltraps>

80107f9d <vector103>:
.globl vector103
vector103:
  pushl $0
80107f9d:	6a 00                	push   $0x0
  pushl $103
80107f9f:	6a 67                	push   $0x67
  jmp alltraps
80107fa1:	e9 0e f6 ff ff       	jmp    801075b4 <alltraps>

80107fa6 <vector104>:
.globl vector104
vector104:
  pushl $0
80107fa6:	6a 00                	push   $0x0
  pushl $104
80107fa8:	6a 68                	push   $0x68
  jmp alltraps
80107faa:	e9 05 f6 ff ff       	jmp    801075b4 <alltraps>

80107faf <vector105>:
.globl vector105
vector105:
  pushl $0
80107faf:	6a 00                	push   $0x0
  pushl $105
80107fb1:	6a 69                	push   $0x69
  jmp alltraps
80107fb3:	e9 fc f5 ff ff       	jmp    801075b4 <alltraps>

80107fb8 <vector106>:
.globl vector106
vector106:
  pushl $0
80107fb8:	6a 00                	push   $0x0
  pushl $106
80107fba:	6a 6a                	push   $0x6a
  jmp alltraps
80107fbc:	e9 f3 f5 ff ff       	jmp    801075b4 <alltraps>

80107fc1 <vector107>:
.globl vector107
vector107:
  pushl $0
80107fc1:	6a 00                	push   $0x0
  pushl $107
80107fc3:	6a 6b                	push   $0x6b
  jmp alltraps
80107fc5:	e9 ea f5 ff ff       	jmp    801075b4 <alltraps>

80107fca <vector108>:
.globl vector108
vector108:
  pushl $0
80107fca:	6a 00                	push   $0x0
  pushl $108
80107fcc:	6a 6c                	push   $0x6c
  jmp alltraps
80107fce:	e9 e1 f5 ff ff       	jmp    801075b4 <alltraps>

80107fd3 <vector109>:
.globl vector109
vector109:
  pushl $0
80107fd3:	6a 00                	push   $0x0
  pushl $109
80107fd5:	6a 6d                	push   $0x6d
  jmp alltraps
80107fd7:	e9 d8 f5 ff ff       	jmp    801075b4 <alltraps>

80107fdc <vector110>:
.globl vector110
vector110:
  pushl $0
80107fdc:	6a 00                	push   $0x0
  pushl $110
80107fde:	6a 6e                	push   $0x6e
  jmp alltraps
80107fe0:	e9 cf f5 ff ff       	jmp    801075b4 <alltraps>

80107fe5 <vector111>:
.globl vector111
vector111:
  pushl $0
80107fe5:	6a 00                	push   $0x0
  pushl $111
80107fe7:	6a 6f                	push   $0x6f
  jmp alltraps
80107fe9:	e9 c6 f5 ff ff       	jmp    801075b4 <alltraps>

80107fee <vector112>:
.globl vector112
vector112:
  pushl $0
80107fee:	6a 00                	push   $0x0
  pushl $112
80107ff0:	6a 70                	push   $0x70
  jmp alltraps
80107ff2:	e9 bd f5 ff ff       	jmp    801075b4 <alltraps>

80107ff7 <vector113>:
.globl vector113
vector113:
  pushl $0
80107ff7:	6a 00                	push   $0x0
  pushl $113
80107ff9:	6a 71                	push   $0x71
  jmp alltraps
80107ffb:	e9 b4 f5 ff ff       	jmp    801075b4 <alltraps>

80108000 <vector114>:
.globl vector114
vector114:
  pushl $0
80108000:	6a 00                	push   $0x0
  pushl $114
80108002:	6a 72                	push   $0x72
  jmp alltraps
80108004:	e9 ab f5 ff ff       	jmp    801075b4 <alltraps>

80108009 <vector115>:
.globl vector115
vector115:
  pushl $0
80108009:	6a 00                	push   $0x0
  pushl $115
8010800b:	6a 73                	push   $0x73
  jmp alltraps
8010800d:	e9 a2 f5 ff ff       	jmp    801075b4 <alltraps>

80108012 <vector116>:
.globl vector116
vector116:
  pushl $0
80108012:	6a 00                	push   $0x0
  pushl $116
80108014:	6a 74                	push   $0x74
  jmp alltraps
80108016:	e9 99 f5 ff ff       	jmp    801075b4 <alltraps>

8010801b <vector117>:
.globl vector117
vector117:
  pushl $0
8010801b:	6a 00                	push   $0x0
  pushl $117
8010801d:	6a 75                	push   $0x75
  jmp alltraps
8010801f:	e9 90 f5 ff ff       	jmp    801075b4 <alltraps>

80108024 <vector118>:
.globl vector118
vector118:
  pushl $0
80108024:	6a 00                	push   $0x0
  pushl $118
80108026:	6a 76                	push   $0x76
  jmp alltraps
80108028:	e9 87 f5 ff ff       	jmp    801075b4 <alltraps>

8010802d <vector119>:
.globl vector119
vector119:
  pushl $0
8010802d:	6a 00                	push   $0x0
  pushl $119
8010802f:	6a 77                	push   $0x77
  jmp alltraps
80108031:	e9 7e f5 ff ff       	jmp    801075b4 <alltraps>

80108036 <vector120>:
.globl vector120
vector120:
  pushl $0
80108036:	6a 00                	push   $0x0
  pushl $120
80108038:	6a 78                	push   $0x78
  jmp alltraps
8010803a:	e9 75 f5 ff ff       	jmp    801075b4 <alltraps>

8010803f <vector121>:
.globl vector121
vector121:
  pushl $0
8010803f:	6a 00                	push   $0x0
  pushl $121
80108041:	6a 79                	push   $0x79
  jmp alltraps
80108043:	e9 6c f5 ff ff       	jmp    801075b4 <alltraps>

80108048 <vector122>:
.globl vector122
vector122:
  pushl $0
80108048:	6a 00                	push   $0x0
  pushl $122
8010804a:	6a 7a                	push   $0x7a
  jmp alltraps
8010804c:	e9 63 f5 ff ff       	jmp    801075b4 <alltraps>

80108051 <vector123>:
.globl vector123
vector123:
  pushl $0
80108051:	6a 00                	push   $0x0
  pushl $123
80108053:	6a 7b                	push   $0x7b
  jmp alltraps
80108055:	e9 5a f5 ff ff       	jmp    801075b4 <alltraps>

8010805a <vector124>:
.globl vector124
vector124:
  pushl $0
8010805a:	6a 00                	push   $0x0
  pushl $124
8010805c:	6a 7c                	push   $0x7c
  jmp alltraps
8010805e:	e9 51 f5 ff ff       	jmp    801075b4 <alltraps>

80108063 <vector125>:
.globl vector125
vector125:
  pushl $0
80108063:	6a 00                	push   $0x0
  pushl $125
80108065:	6a 7d                	push   $0x7d
  jmp alltraps
80108067:	e9 48 f5 ff ff       	jmp    801075b4 <alltraps>

8010806c <vector126>:
.globl vector126
vector126:
  pushl $0
8010806c:	6a 00                	push   $0x0
  pushl $126
8010806e:	6a 7e                	push   $0x7e
  jmp alltraps
80108070:	e9 3f f5 ff ff       	jmp    801075b4 <alltraps>

80108075 <vector127>:
.globl vector127
vector127:
  pushl $0
80108075:	6a 00                	push   $0x0
  pushl $127
80108077:	6a 7f                	push   $0x7f
  jmp alltraps
80108079:	e9 36 f5 ff ff       	jmp    801075b4 <alltraps>

8010807e <vector128>:
.globl vector128
vector128:
  pushl $0
8010807e:	6a 00                	push   $0x0
  pushl $128
80108080:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80108085:	e9 2a f5 ff ff       	jmp    801075b4 <alltraps>

8010808a <vector129>:
.globl vector129
vector129:
  pushl $0
8010808a:	6a 00                	push   $0x0
  pushl $129
8010808c:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80108091:	e9 1e f5 ff ff       	jmp    801075b4 <alltraps>

80108096 <vector130>:
.globl vector130
vector130:
  pushl $0
80108096:	6a 00                	push   $0x0
  pushl $130
80108098:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010809d:	e9 12 f5 ff ff       	jmp    801075b4 <alltraps>

801080a2 <vector131>:
.globl vector131
vector131:
  pushl $0
801080a2:	6a 00                	push   $0x0
  pushl $131
801080a4:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801080a9:	e9 06 f5 ff ff       	jmp    801075b4 <alltraps>

801080ae <vector132>:
.globl vector132
vector132:
  pushl $0
801080ae:	6a 00                	push   $0x0
  pushl $132
801080b0:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801080b5:	e9 fa f4 ff ff       	jmp    801075b4 <alltraps>

801080ba <vector133>:
.globl vector133
vector133:
  pushl $0
801080ba:	6a 00                	push   $0x0
  pushl $133
801080bc:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801080c1:	e9 ee f4 ff ff       	jmp    801075b4 <alltraps>

801080c6 <vector134>:
.globl vector134
vector134:
  pushl $0
801080c6:	6a 00                	push   $0x0
  pushl $134
801080c8:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801080cd:	e9 e2 f4 ff ff       	jmp    801075b4 <alltraps>

801080d2 <vector135>:
.globl vector135
vector135:
  pushl $0
801080d2:	6a 00                	push   $0x0
  pushl $135
801080d4:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801080d9:	e9 d6 f4 ff ff       	jmp    801075b4 <alltraps>

801080de <vector136>:
.globl vector136
vector136:
  pushl $0
801080de:	6a 00                	push   $0x0
  pushl $136
801080e0:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801080e5:	e9 ca f4 ff ff       	jmp    801075b4 <alltraps>

801080ea <vector137>:
.globl vector137
vector137:
  pushl $0
801080ea:	6a 00                	push   $0x0
  pushl $137
801080ec:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801080f1:	e9 be f4 ff ff       	jmp    801075b4 <alltraps>

801080f6 <vector138>:
.globl vector138
vector138:
  pushl $0
801080f6:	6a 00                	push   $0x0
  pushl $138
801080f8:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801080fd:	e9 b2 f4 ff ff       	jmp    801075b4 <alltraps>

80108102 <vector139>:
.globl vector139
vector139:
  pushl $0
80108102:	6a 00                	push   $0x0
  pushl $139
80108104:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80108109:	e9 a6 f4 ff ff       	jmp    801075b4 <alltraps>

8010810e <vector140>:
.globl vector140
vector140:
  pushl $0
8010810e:	6a 00                	push   $0x0
  pushl $140
80108110:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80108115:	e9 9a f4 ff ff       	jmp    801075b4 <alltraps>

8010811a <vector141>:
.globl vector141
vector141:
  pushl $0
8010811a:	6a 00                	push   $0x0
  pushl $141
8010811c:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80108121:	e9 8e f4 ff ff       	jmp    801075b4 <alltraps>

80108126 <vector142>:
.globl vector142
vector142:
  pushl $0
80108126:	6a 00                	push   $0x0
  pushl $142
80108128:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010812d:	e9 82 f4 ff ff       	jmp    801075b4 <alltraps>

80108132 <vector143>:
.globl vector143
vector143:
  pushl $0
80108132:	6a 00                	push   $0x0
  pushl $143
80108134:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80108139:	e9 76 f4 ff ff       	jmp    801075b4 <alltraps>

8010813e <vector144>:
.globl vector144
vector144:
  pushl $0
8010813e:	6a 00                	push   $0x0
  pushl $144
80108140:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80108145:	e9 6a f4 ff ff       	jmp    801075b4 <alltraps>

8010814a <vector145>:
.globl vector145
vector145:
  pushl $0
8010814a:	6a 00                	push   $0x0
  pushl $145
8010814c:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80108151:	e9 5e f4 ff ff       	jmp    801075b4 <alltraps>

80108156 <vector146>:
.globl vector146
vector146:
  pushl $0
80108156:	6a 00                	push   $0x0
  pushl $146
80108158:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010815d:	e9 52 f4 ff ff       	jmp    801075b4 <alltraps>

80108162 <vector147>:
.globl vector147
vector147:
  pushl $0
80108162:	6a 00                	push   $0x0
  pushl $147
80108164:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80108169:	e9 46 f4 ff ff       	jmp    801075b4 <alltraps>

8010816e <vector148>:
.globl vector148
vector148:
  pushl $0
8010816e:	6a 00                	push   $0x0
  pushl $148
80108170:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80108175:	e9 3a f4 ff ff       	jmp    801075b4 <alltraps>

8010817a <vector149>:
.globl vector149
vector149:
  pushl $0
8010817a:	6a 00                	push   $0x0
  pushl $149
8010817c:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80108181:	e9 2e f4 ff ff       	jmp    801075b4 <alltraps>

80108186 <vector150>:
.globl vector150
vector150:
  pushl $0
80108186:	6a 00                	push   $0x0
  pushl $150
80108188:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010818d:	e9 22 f4 ff ff       	jmp    801075b4 <alltraps>

80108192 <vector151>:
.globl vector151
vector151:
  pushl $0
80108192:	6a 00                	push   $0x0
  pushl $151
80108194:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80108199:	e9 16 f4 ff ff       	jmp    801075b4 <alltraps>

8010819e <vector152>:
.globl vector152
vector152:
  pushl $0
8010819e:	6a 00                	push   $0x0
  pushl $152
801081a0:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801081a5:	e9 0a f4 ff ff       	jmp    801075b4 <alltraps>

801081aa <vector153>:
.globl vector153
vector153:
  pushl $0
801081aa:	6a 00                	push   $0x0
  pushl $153
801081ac:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801081b1:	e9 fe f3 ff ff       	jmp    801075b4 <alltraps>

801081b6 <vector154>:
.globl vector154
vector154:
  pushl $0
801081b6:	6a 00                	push   $0x0
  pushl $154
801081b8:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801081bd:	e9 f2 f3 ff ff       	jmp    801075b4 <alltraps>

801081c2 <vector155>:
.globl vector155
vector155:
  pushl $0
801081c2:	6a 00                	push   $0x0
  pushl $155
801081c4:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801081c9:	e9 e6 f3 ff ff       	jmp    801075b4 <alltraps>

801081ce <vector156>:
.globl vector156
vector156:
  pushl $0
801081ce:	6a 00                	push   $0x0
  pushl $156
801081d0:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801081d5:	e9 da f3 ff ff       	jmp    801075b4 <alltraps>

801081da <vector157>:
.globl vector157
vector157:
  pushl $0
801081da:	6a 00                	push   $0x0
  pushl $157
801081dc:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801081e1:	e9 ce f3 ff ff       	jmp    801075b4 <alltraps>

801081e6 <vector158>:
.globl vector158
vector158:
  pushl $0
801081e6:	6a 00                	push   $0x0
  pushl $158
801081e8:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801081ed:	e9 c2 f3 ff ff       	jmp    801075b4 <alltraps>

801081f2 <vector159>:
.globl vector159
vector159:
  pushl $0
801081f2:	6a 00                	push   $0x0
  pushl $159
801081f4:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801081f9:	e9 b6 f3 ff ff       	jmp    801075b4 <alltraps>

801081fe <vector160>:
.globl vector160
vector160:
  pushl $0
801081fe:	6a 00                	push   $0x0
  pushl $160
80108200:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80108205:	e9 aa f3 ff ff       	jmp    801075b4 <alltraps>

8010820a <vector161>:
.globl vector161
vector161:
  pushl $0
8010820a:	6a 00                	push   $0x0
  pushl $161
8010820c:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80108211:	e9 9e f3 ff ff       	jmp    801075b4 <alltraps>

80108216 <vector162>:
.globl vector162
vector162:
  pushl $0
80108216:	6a 00                	push   $0x0
  pushl $162
80108218:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010821d:	e9 92 f3 ff ff       	jmp    801075b4 <alltraps>

80108222 <vector163>:
.globl vector163
vector163:
  pushl $0
80108222:	6a 00                	push   $0x0
  pushl $163
80108224:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80108229:	e9 86 f3 ff ff       	jmp    801075b4 <alltraps>

8010822e <vector164>:
.globl vector164
vector164:
  pushl $0
8010822e:	6a 00                	push   $0x0
  pushl $164
80108230:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80108235:	e9 7a f3 ff ff       	jmp    801075b4 <alltraps>

8010823a <vector165>:
.globl vector165
vector165:
  pushl $0
8010823a:	6a 00                	push   $0x0
  pushl $165
8010823c:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80108241:	e9 6e f3 ff ff       	jmp    801075b4 <alltraps>

80108246 <vector166>:
.globl vector166
vector166:
  pushl $0
80108246:	6a 00                	push   $0x0
  pushl $166
80108248:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010824d:	e9 62 f3 ff ff       	jmp    801075b4 <alltraps>

80108252 <vector167>:
.globl vector167
vector167:
  pushl $0
80108252:	6a 00                	push   $0x0
  pushl $167
80108254:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80108259:	e9 56 f3 ff ff       	jmp    801075b4 <alltraps>

8010825e <vector168>:
.globl vector168
vector168:
  pushl $0
8010825e:	6a 00                	push   $0x0
  pushl $168
80108260:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80108265:	e9 4a f3 ff ff       	jmp    801075b4 <alltraps>

8010826a <vector169>:
.globl vector169
vector169:
  pushl $0
8010826a:	6a 00                	push   $0x0
  pushl $169
8010826c:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80108271:	e9 3e f3 ff ff       	jmp    801075b4 <alltraps>

80108276 <vector170>:
.globl vector170
vector170:
  pushl $0
80108276:	6a 00                	push   $0x0
  pushl $170
80108278:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010827d:	e9 32 f3 ff ff       	jmp    801075b4 <alltraps>

80108282 <vector171>:
.globl vector171
vector171:
  pushl $0
80108282:	6a 00                	push   $0x0
  pushl $171
80108284:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80108289:	e9 26 f3 ff ff       	jmp    801075b4 <alltraps>

8010828e <vector172>:
.globl vector172
vector172:
  pushl $0
8010828e:	6a 00                	push   $0x0
  pushl $172
80108290:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80108295:	e9 1a f3 ff ff       	jmp    801075b4 <alltraps>

8010829a <vector173>:
.globl vector173
vector173:
  pushl $0
8010829a:	6a 00                	push   $0x0
  pushl $173
8010829c:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801082a1:	e9 0e f3 ff ff       	jmp    801075b4 <alltraps>

801082a6 <vector174>:
.globl vector174
vector174:
  pushl $0
801082a6:	6a 00                	push   $0x0
  pushl $174
801082a8:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801082ad:	e9 02 f3 ff ff       	jmp    801075b4 <alltraps>

801082b2 <vector175>:
.globl vector175
vector175:
  pushl $0
801082b2:	6a 00                	push   $0x0
  pushl $175
801082b4:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801082b9:	e9 f6 f2 ff ff       	jmp    801075b4 <alltraps>

801082be <vector176>:
.globl vector176
vector176:
  pushl $0
801082be:	6a 00                	push   $0x0
  pushl $176
801082c0:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801082c5:	e9 ea f2 ff ff       	jmp    801075b4 <alltraps>

801082ca <vector177>:
.globl vector177
vector177:
  pushl $0
801082ca:	6a 00                	push   $0x0
  pushl $177
801082cc:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801082d1:	e9 de f2 ff ff       	jmp    801075b4 <alltraps>

801082d6 <vector178>:
.globl vector178
vector178:
  pushl $0
801082d6:	6a 00                	push   $0x0
  pushl $178
801082d8:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801082dd:	e9 d2 f2 ff ff       	jmp    801075b4 <alltraps>

801082e2 <vector179>:
.globl vector179
vector179:
  pushl $0
801082e2:	6a 00                	push   $0x0
  pushl $179
801082e4:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801082e9:	e9 c6 f2 ff ff       	jmp    801075b4 <alltraps>

801082ee <vector180>:
.globl vector180
vector180:
  pushl $0
801082ee:	6a 00                	push   $0x0
  pushl $180
801082f0:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801082f5:	e9 ba f2 ff ff       	jmp    801075b4 <alltraps>

801082fa <vector181>:
.globl vector181
vector181:
  pushl $0
801082fa:	6a 00                	push   $0x0
  pushl $181
801082fc:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80108301:	e9 ae f2 ff ff       	jmp    801075b4 <alltraps>

80108306 <vector182>:
.globl vector182
vector182:
  pushl $0
80108306:	6a 00                	push   $0x0
  pushl $182
80108308:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010830d:	e9 a2 f2 ff ff       	jmp    801075b4 <alltraps>

80108312 <vector183>:
.globl vector183
vector183:
  pushl $0
80108312:	6a 00                	push   $0x0
  pushl $183
80108314:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80108319:	e9 96 f2 ff ff       	jmp    801075b4 <alltraps>

8010831e <vector184>:
.globl vector184
vector184:
  pushl $0
8010831e:	6a 00                	push   $0x0
  pushl $184
80108320:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80108325:	e9 8a f2 ff ff       	jmp    801075b4 <alltraps>

8010832a <vector185>:
.globl vector185
vector185:
  pushl $0
8010832a:	6a 00                	push   $0x0
  pushl $185
8010832c:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80108331:	e9 7e f2 ff ff       	jmp    801075b4 <alltraps>

80108336 <vector186>:
.globl vector186
vector186:
  pushl $0
80108336:	6a 00                	push   $0x0
  pushl $186
80108338:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010833d:	e9 72 f2 ff ff       	jmp    801075b4 <alltraps>

80108342 <vector187>:
.globl vector187
vector187:
  pushl $0
80108342:	6a 00                	push   $0x0
  pushl $187
80108344:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80108349:	e9 66 f2 ff ff       	jmp    801075b4 <alltraps>

8010834e <vector188>:
.globl vector188
vector188:
  pushl $0
8010834e:	6a 00                	push   $0x0
  pushl $188
80108350:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80108355:	e9 5a f2 ff ff       	jmp    801075b4 <alltraps>

8010835a <vector189>:
.globl vector189
vector189:
  pushl $0
8010835a:	6a 00                	push   $0x0
  pushl $189
8010835c:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80108361:	e9 4e f2 ff ff       	jmp    801075b4 <alltraps>

80108366 <vector190>:
.globl vector190
vector190:
  pushl $0
80108366:	6a 00                	push   $0x0
  pushl $190
80108368:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010836d:	e9 42 f2 ff ff       	jmp    801075b4 <alltraps>

80108372 <vector191>:
.globl vector191
vector191:
  pushl $0
80108372:	6a 00                	push   $0x0
  pushl $191
80108374:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80108379:	e9 36 f2 ff ff       	jmp    801075b4 <alltraps>

8010837e <vector192>:
.globl vector192
vector192:
  pushl $0
8010837e:	6a 00                	push   $0x0
  pushl $192
80108380:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80108385:	e9 2a f2 ff ff       	jmp    801075b4 <alltraps>

8010838a <vector193>:
.globl vector193
vector193:
  pushl $0
8010838a:	6a 00                	push   $0x0
  pushl $193
8010838c:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80108391:	e9 1e f2 ff ff       	jmp    801075b4 <alltraps>

80108396 <vector194>:
.globl vector194
vector194:
  pushl $0
80108396:	6a 00                	push   $0x0
  pushl $194
80108398:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010839d:	e9 12 f2 ff ff       	jmp    801075b4 <alltraps>

801083a2 <vector195>:
.globl vector195
vector195:
  pushl $0
801083a2:	6a 00                	push   $0x0
  pushl $195
801083a4:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801083a9:	e9 06 f2 ff ff       	jmp    801075b4 <alltraps>

801083ae <vector196>:
.globl vector196
vector196:
  pushl $0
801083ae:	6a 00                	push   $0x0
  pushl $196
801083b0:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801083b5:	e9 fa f1 ff ff       	jmp    801075b4 <alltraps>

801083ba <vector197>:
.globl vector197
vector197:
  pushl $0
801083ba:	6a 00                	push   $0x0
  pushl $197
801083bc:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801083c1:	e9 ee f1 ff ff       	jmp    801075b4 <alltraps>

801083c6 <vector198>:
.globl vector198
vector198:
  pushl $0
801083c6:	6a 00                	push   $0x0
  pushl $198
801083c8:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801083cd:	e9 e2 f1 ff ff       	jmp    801075b4 <alltraps>

801083d2 <vector199>:
.globl vector199
vector199:
  pushl $0
801083d2:	6a 00                	push   $0x0
  pushl $199
801083d4:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801083d9:	e9 d6 f1 ff ff       	jmp    801075b4 <alltraps>

801083de <vector200>:
.globl vector200
vector200:
  pushl $0
801083de:	6a 00                	push   $0x0
  pushl $200
801083e0:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801083e5:	e9 ca f1 ff ff       	jmp    801075b4 <alltraps>

801083ea <vector201>:
.globl vector201
vector201:
  pushl $0
801083ea:	6a 00                	push   $0x0
  pushl $201
801083ec:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801083f1:	e9 be f1 ff ff       	jmp    801075b4 <alltraps>

801083f6 <vector202>:
.globl vector202
vector202:
  pushl $0
801083f6:	6a 00                	push   $0x0
  pushl $202
801083f8:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801083fd:	e9 b2 f1 ff ff       	jmp    801075b4 <alltraps>

80108402 <vector203>:
.globl vector203
vector203:
  pushl $0
80108402:	6a 00                	push   $0x0
  pushl $203
80108404:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80108409:	e9 a6 f1 ff ff       	jmp    801075b4 <alltraps>

8010840e <vector204>:
.globl vector204
vector204:
  pushl $0
8010840e:	6a 00                	push   $0x0
  pushl $204
80108410:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80108415:	e9 9a f1 ff ff       	jmp    801075b4 <alltraps>

8010841a <vector205>:
.globl vector205
vector205:
  pushl $0
8010841a:	6a 00                	push   $0x0
  pushl $205
8010841c:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80108421:	e9 8e f1 ff ff       	jmp    801075b4 <alltraps>

80108426 <vector206>:
.globl vector206
vector206:
  pushl $0
80108426:	6a 00                	push   $0x0
  pushl $206
80108428:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010842d:	e9 82 f1 ff ff       	jmp    801075b4 <alltraps>

80108432 <vector207>:
.globl vector207
vector207:
  pushl $0
80108432:	6a 00                	push   $0x0
  pushl $207
80108434:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80108439:	e9 76 f1 ff ff       	jmp    801075b4 <alltraps>

8010843e <vector208>:
.globl vector208
vector208:
  pushl $0
8010843e:	6a 00                	push   $0x0
  pushl $208
80108440:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80108445:	e9 6a f1 ff ff       	jmp    801075b4 <alltraps>

8010844a <vector209>:
.globl vector209
vector209:
  pushl $0
8010844a:	6a 00                	push   $0x0
  pushl $209
8010844c:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80108451:	e9 5e f1 ff ff       	jmp    801075b4 <alltraps>

80108456 <vector210>:
.globl vector210
vector210:
  pushl $0
80108456:	6a 00                	push   $0x0
  pushl $210
80108458:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010845d:	e9 52 f1 ff ff       	jmp    801075b4 <alltraps>

80108462 <vector211>:
.globl vector211
vector211:
  pushl $0
80108462:	6a 00                	push   $0x0
  pushl $211
80108464:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80108469:	e9 46 f1 ff ff       	jmp    801075b4 <alltraps>

8010846e <vector212>:
.globl vector212
vector212:
  pushl $0
8010846e:	6a 00                	push   $0x0
  pushl $212
80108470:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80108475:	e9 3a f1 ff ff       	jmp    801075b4 <alltraps>

8010847a <vector213>:
.globl vector213
vector213:
  pushl $0
8010847a:	6a 00                	push   $0x0
  pushl $213
8010847c:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80108481:	e9 2e f1 ff ff       	jmp    801075b4 <alltraps>

80108486 <vector214>:
.globl vector214
vector214:
  pushl $0
80108486:	6a 00                	push   $0x0
  pushl $214
80108488:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010848d:	e9 22 f1 ff ff       	jmp    801075b4 <alltraps>

80108492 <vector215>:
.globl vector215
vector215:
  pushl $0
80108492:	6a 00                	push   $0x0
  pushl $215
80108494:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80108499:	e9 16 f1 ff ff       	jmp    801075b4 <alltraps>

8010849e <vector216>:
.globl vector216
vector216:
  pushl $0
8010849e:	6a 00                	push   $0x0
  pushl $216
801084a0:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801084a5:	e9 0a f1 ff ff       	jmp    801075b4 <alltraps>

801084aa <vector217>:
.globl vector217
vector217:
  pushl $0
801084aa:	6a 00                	push   $0x0
  pushl $217
801084ac:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801084b1:	e9 fe f0 ff ff       	jmp    801075b4 <alltraps>

801084b6 <vector218>:
.globl vector218
vector218:
  pushl $0
801084b6:	6a 00                	push   $0x0
  pushl $218
801084b8:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801084bd:	e9 f2 f0 ff ff       	jmp    801075b4 <alltraps>

801084c2 <vector219>:
.globl vector219
vector219:
  pushl $0
801084c2:	6a 00                	push   $0x0
  pushl $219
801084c4:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801084c9:	e9 e6 f0 ff ff       	jmp    801075b4 <alltraps>

801084ce <vector220>:
.globl vector220
vector220:
  pushl $0
801084ce:	6a 00                	push   $0x0
  pushl $220
801084d0:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801084d5:	e9 da f0 ff ff       	jmp    801075b4 <alltraps>

801084da <vector221>:
.globl vector221
vector221:
  pushl $0
801084da:	6a 00                	push   $0x0
  pushl $221
801084dc:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801084e1:	e9 ce f0 ff ff       	jmp    801075b4 <alltraps>

801084e6 <vector222>:
.globl vector222
vector222:
  pushl $0
801084e6:	6a 00                	push   $0x0
  pushl $222
801084e8:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801084ed:	e9 c2 f0 ff ff       	jmp    801075b4 <alltraps>

801084f2 <vector223>:
.globl vector223
vector223:
  pushl $0
801084f2:	6a 00                	push   $0x0
  pushl $223
801084f4:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801084f9:	e9 b6 f0 ff ff       	jmp    801075b4 <alltraps>

801084fe <vector224>:
.globl vector224
vector224:
  pushl $0
801084fe:	6a 00                	push   $0x0
  pushl $224
80108500:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80108505:	e9 aa f0 ff ff       	jmp    801075b4 <alltraps>

8010850a <vector225>:
.globl vector225
vector225:
  pushl $0
8010850a:	6a 00                	push   $0x0
  pushl $225
8010850c:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80108511:	e9 9e f0 ff ff       	jmp    801075b4 <alltraps>

80108516 <vector226>:
.globl vector226
vector226:
  pushl $0
80108516:	6a 00                	push   $0x0
  pushl $226
80108518:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010851d:	e9 92 f0 ff ff       	jmp    801075b4 <alltraps>

80108522 <vector227>:
.globl vector227
vector227:
  pushl $0
80108522:	6a 00                	push   $0x0
  pushl $227
80108524:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80108529:	e9 86 f0 ff ff       	jmp    801075b4 <alltraps>

8010852e <vector228>:
.globl vector228
vector228:
  pushl $0
8010852e:	6a 00                	push   $0x0
  pushl $228
80108530:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80108535:	e9 7a f0 ff ff       	jmp    801075b4 <alltraps>

8010853a <vector229>:
.globl vector229
vector229:
  pushl $0
8010853a:	6a 00                	push   $0x0
  pushl $229
8010853c:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80108541:	e9 6e f0 ff ff       	jmp    801075b4 <alltraps>

80108546 <vector230>:
.globl vector230
vector230:
  pushl $0
80108546:	6a 00                	push   $0x0
  pushl $230
80108548:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010854d:	e9 62 f0 ff ff       	jmp    801075b4 <alltraps>

80108552 <vector231>:
.globl vector231
vector231:
  pushl $0
80108552:	6a 00                	push   $0x0
  pushl $231
80108554:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80108559:	e9 56 f0 ff ff       	jmp    801075b4 <alltraps>

8010855e <vector232>:
.globl vector232
vector232:
  pushl $0
8010855e:	6a 00                	push   $0x0
  pushl $232
80108560:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80108565:	e9 4a f0 ff ff       	jmp    801075b4 <alltraps>

8010856a <vector233>:
.globl vector233
vector233:
  pushl $0
8010856a:	6a 00                	push   $0x0
  pushl $233
8010856c:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80108571:	e9 3e f0 ff ff       	jmp    801075b4 <alltraps>

80108576 <vector234>:
.globl vector234
vector234:
  pushl $0
80108576:	6a 00                	push   $0x0
  pushl $234
80108578:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010857d:	e9 32 f0 ff ff       	jmp    801075b4 <alltraps>

80108582 <vector235>:
.globl vector235
vector235:
  pushl $0
80108582:	6a 00                	push   $0x0
  pushl $235
80108584:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80108589:	e9 26 f0 ff ff       	jmp    801075b4 <alltraps>

8010858e <vector236>:
.globl vector236
vector236:
  pushl $0
8010858e:	6a 00                	push   $0x0
  pushl $236
80108590:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80108595:	e9 1a f0 ff ff       	jmp    801075b4 <alltraps>

8010859a <vector237>:
.globl vector237
vector237:
  pushl $0
8010859a:	6a 00                	push   $0x0
  pushl $237
8010859c:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801085a1:	e9 0e f0 ff ff       	jmp    801075b4 <alltraps>

801085a6 <vector238>:
.globl vector238
vector238:
  pushl $0
801085a6:	6a 00                	push   $0x0
  pushl $238
801085a8:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801085ad:	e9 02 f0 ff ff       	jmp    801075b4 <alltraps>

801085b2 <vector239>:
.globl vector239
vector239:
  pushl $0
801085b2:	6a 00                	push   $0x0
  pushl $239
801085b4:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801085b9:	e9 f6 ef ff ff       	jmp    801075b4 <alltraps>

801085be <vector240>:
.globl vector240
vector240:
  pushl $0
801085be:	6a 00                	push   $0x0
  pushl $240
801085c0:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801085c5:	e9 ea ef ff ff       	jmp    801075b4 <alltraps>

801085ca <vector241>:
.globl vector241
vector241:
  pushl $0
801085ca:	6a 00                	push   $0x0
  pushl $241
801085cc:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801085d1:	e9 de ef ff ff       	jmp    801075b4 <alltraps>

801085d6 <vector242>:
.globl vector242
vector242:
  pushl $0
801085d6:	6a 00                	push   $0x0
  pushl $242
801085d8:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801085dd:	e9 d2 ef ff ff       	jmp    801075b4 <alltraps>

801085e2 <vector243>:
.globl vector243
vector243:
  pushl $0
801085e2:	6a 00                	push   $0x0
  pushl $243
801085e4:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801085e9:	e9 c6 ef ff ff       	jmp    801075b4 <alltraps>

801085ee <vector244>:
.globl vector244
vector244:
  pushl $0
801085ee:	6a 00                	push   $0x0
  pushl $244
801085f0:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801085f5:	e9 ba ef ff ff       	jmp    801075b4 <alltraps>

801085fa <vector245>:
.globl vector245
vector245:
  pushl $0
801085fa:	6a 00                	push   $0x0
  pushl $245
801085fc:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80108601:	e9 ae ef ff ff       	jmp    801075b4 <alltraps>

80108606 <vector246>:
.globl vector246
vector246:
  pushl $0
80108606:	6a 00                	push   $0x0
  pushl $246
80108608:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010860d:	e9 a2 ef ff ff       	jmp    801075b4 <alltraps>

80108612 <vector247>:
.globl vector247
vector247:
  pushl $0
80108612:	6a 00                	push   $0x0
  pushl $247
80108614:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80108619:	e9 96 ef ff ff       	jmp    801075b4 <alltraps>

8010861e <vector248>:
.globl vector248
vector248:
  pushl $0
8010861e:	6a 00                	push   $0x0
  pushl $248
80108620:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80108625:	e9 8a ef ff ff       	jmp    801075b4 <alltraps>

8010862a <vector249>:
.globl vector249
vector249:
  pushl $0
8010862a:	6a 00                	push   $0x0
  pushl $249
8010862c:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80108631:	e9 7e ef ff ff       	jmp    801075b4 <alltraps>

80108636 <vector250>:
.globl vector250
vector250:
  pushl $0
80108636:	6a 00                	push   $0x0
  pushl $250
80108638:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010863d:	e9 72 ef ff ff       	jmp    801075b4 <alltraps>

80108642 <vector251>:
.globl vector251
vector251:
  pushl $0
80108642:	6a 00                	push   $0x0
  pushl $251
80108644:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80108649:	e9 66 ef ff ff       	jmp    801075b4 <alltraps>

8010864e <vector252>:
.globl vector252
vector252:
  pushl $0
8010864e:	6a 00                	push   $0x0
  pushl $252
80108650:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80108655:	e9 5a ef ff ff       	jmp    801075b4 <alltraps>

8010865a <vector253>:
.globl vector253
vector253:
  pushl $0
8010865a:	6a 00                	push   $0x0
  pushl $253
8010865c:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80108661:	e9 4e ef ff ff       	jmp    801075b4 <alltraps>

80108666 <vector254>:
.globl vector254
vector254:
  pushl $0
80108666:	6a 00                	push   $0x0
  pushl $254
80108668:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010866d:	e9 42 ef ff ff       	jmp    801075b4 <alltraps>

80108672 <vector255>:
.globl vector255
vector255:
  pushl $0
80108672:	6a 00                	push   $0x0
  pushl $255
80108674:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80108679:	e9 36 ef ff ff       	jmp    801075b4 <alltraps>
	...

80108680 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80108680:	55                   	push   %ebp
80108681:	89 e5                	mov    %esp,%ebp
80108683:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80108686:	8b 45 0c             	mov    0xc(%ebp),%eax
80108689:	48                   	dec    %eax
8010868a:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010868e:	8b 45 08             	mov    0x8(%ebp),%eax
80108691:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80108695:	8b 45 08             	mov    0x8(%ebp),%eax
80108698:	c1 e8 10             	shr    $0x10,%eax
8010869b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
8010869f:	8d 45 fa             	lea    -0x6(%ebp),%eax
801086a2:	0f 01 10             	lgdtl  (%eax)
}
801086a5:	c9                   	leave  
801086a6:	c3                   	ret    

801086a7 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801086a7:	55                   	push   %ebp
801086a8:	89 e5                	mov    %esp,%ebp
801086aa:	83 ec 04             	sub    $0x4,%esp
801086ad:	8b 45 08             	mov    0x8(%ebp),%eax
801086b0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801086b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801086b7:	0f 00 d8             	ltr    %ax
}
801086ba:	c9                   	leave  
801086bb:	c3                   	ret    

801086bc <lcr3>:
  return val;
}

static inline void
lcr3(uint val)
{
801086bc:	55                   	push   %ebp
801086bd:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801086bf:	8b 45 08             	mov    0x8(%ebp),%eax
801086c2:	0f 22 d8             	mov    %eax,%cr3
}
801086c5:	5d                   	pop    %ebp
801086c6:	c3                   	ret    

801086c7 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801086c7:	55                   	push   %ebp
801086c8:	89 e5                	mov    %esp,%ebp
801086ca:	83 ec 28             	sub    $0x28,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
801086cd:	e8 0c be ff ff       	call   801044de <cpuid>
801086d2:	89 c2                	mov    %eax,%edx
801086d4:	89 d0                	mov    %edx,%eax
801086d6:	c1 e0 02             	shl    $0x2,%eax
801086d9:	01 d0                	add    %edx,%eax
801086db:	01 c0                	add    %eax,%eax
801086dd:	01 d0                	add    %edx,%eax
801086df:	c1 e0 04             	shl    $0x4,%eax
801086e2:	05 20 5d 11 80       	add    $0x80115d20,%eax
801086e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801086ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ed:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801086f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f6:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801086fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ff:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80108703:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108706:	8a 50 7d             	mov    0x7d(%eax),%dl
80108709:	83 e2 f0             	and    $0xfffffff0,%edx
8010870c:	83 ca 0a             	or     $0xa,%edx
8010870f:	88 50 7d             	mov    %dl,0x7d(%eax)
80108712:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108715:	8a 50 7d             	mov    0x7d(%eax),%dl
80108718:	83 ca 10             	or     $0x10,%edx
8010871b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010871e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108721:	8a 50 7d             	mov    0x7d(%eax),%dl
80108724:	83 e2 9f             	and    $0xffffff9f,%edx
80108727:	88 50 7d             	mov    %dl,0x7d(%eax)
8010872a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010872d:	8a 50 7d             	mov    0x7d(%eax),%dl
80108730:	83 ca 80             	or     $0xffffff80,%edx
80108733:	88 50 7d             	mov    %dl,0x7d(%eax)
80108736:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108739:	8a 50 7e             	mov    0x7e(%eax),%dl
8010873c:	83 ca 0f             	or     $0xf,%edx
8010873f:	88 50 7e             	mov    %dl,0x7e(%eax)
80108742:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108745:	8a 50 7e             	mov    0x7e(%eax),%dl
80108748:	83 e2 ef             	and    $0xffffffef,%edx
8010874b:	88 50 7e             	mov    %dl,0x7e(%eax)
8010874e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108751:	8a 50 7e             	mov    0x7e(%eax),%dl
80108754:	83 e2 df             	and    $0xffffffdf,%edx
80108757:	88 50 7e             	mov    %dl,0x7e(%eax)
8010875a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010875d:	8a 50 7e             	mov    0x7e(%eax),%dl
80108760:	83 ca 40             	or     $0x40,%edx
80108763:	88 50 7e             	mov    %dl,0x7e(%eax)
80108766:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108769:	8a 50 7e             	mov    0x7e(%eax),%dl
8010876c:	83 ca 80             	or     $0xffffff80,%edx
8010876f:	88 50 7e             	mov    %dl,0x7e(%eax)
80108772:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108775:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80108779:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010877c:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80108783:	ff ff 
80108785:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108788:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010878f:	00 00 
80108791:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108794:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010879b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010879e:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
801087a4:	83 e2 f0             	and    $0xfffffff0,%edx
801087a7:	83 ca 02             	or     $0x2,%edx
801087aa:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801087b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087b3:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
801087b9:	83 ca 10             	or     $0x10,%edx
801087bc:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801087c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087c5:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
801087cb:	83 e2 9f             	and    $0xffffff9f,%edx
801087ce:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801087d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087d7:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
801087dd:	83 ca 80             	or     $0xffffff80,%edx
801087e0:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801087e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087e9:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
801087ef:	83 ca 0f             	or     $0xf,%edx
801087f2:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801087f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087fb:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80108801:	83 e2 ef             	and    $0xffffffef,%edx
80108804:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010880a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010880d:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80108813:	83 e2 df             	and    $0xffffffdf,%edx
80108816:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010881c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010881f:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80108825:	83 ca 40             	or     $0x40,%edx
80108828:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010882e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108831:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80108837:	83 ca 80             	or     $0xffffff80,%edx
8010883a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108840:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108843:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010884a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010884d:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80108854:	ff ff 
80108856:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108859:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80108860:	00 00 
80108862:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108865:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
8010886c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010886f:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80108875:	83 e2 f0             	and    $0xfffffff0,%edx
80108878:	83 ca 0a             	or     $0xa,%edx
8010887b:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108881:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108884:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
8010888a:	83 ca 10             	or     $0x10,%edx
8010888d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108893:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108896:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
8010889c:	83 ca 60             	or     $0x60,%edx
8010889f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801088a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088a8:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
801088ae:	83 ca 80             	or     $0xffffff80,%edx
801088b1:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801088b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ba:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
801088c0:	83 ca 0f             	or     $0xf,%edx
801088c3:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801088c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088cc:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
801088d2:	83 e2 ef             	and    $0xffffffef,%edx
801088d5:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801088db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088de:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
801088e4:	83 e2 df             	and    $0xffffffdf,%edx
801088e7:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801088ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088f0:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
801088f6:	83 ca 40             	or     $0x40,%edx
801088f9:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801088ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108902:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80108908:	83 ca 80             	or     $0xffffff80,%edx
8010890b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108911:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108914:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010891b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010891e:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80108925:	ff ff 
80108927:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010892a:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80108931:	00 00 
80108933:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108936:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010893d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108940:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80108946:	83 e2 f0             	and    $0xfffffff0,%edx
80108949:	83 ca 02             	or     $0x2,%edx
8010894c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108952:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108955:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
8010895b:	83 ca 10             	or     $0x10,%edx
8010895e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108964:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108967:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
8010896d:	83 ca 60             	or     $0x60,%edx
80108970:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108976:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108979:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
8010897f:	83 ca 80             	or     $0xffffff80,%edx
80108982:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108988:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010898b:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80108991:	83 ca 0f             	or     $0xf,%edx
80108994:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010899a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010899d:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
801089a3:	83 e2 ef             	and    $0xffffffef,%edx
801089a6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801089ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089af:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
801089b5:	83 e2 df             	and    $0xffffffdf,%edx
801089b8:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801089be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089c1:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
801089c7:	83 ca 40             	or     $0x40,%edx
801089ca:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801089d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089d3:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
801089d9:	83 ca 80             	or     $0xffffff80,%edx
801089dc:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801089e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089e5:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801089ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ef:	83 c0 70             	add    $0x70,%eax
801089f2:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
801089f9:	00 
801089fa:	89 04 24             	mov    %eax,(%esp)
801089fd:	e8 7e fc ff ff       	call   80108680 <lgdt>
}
80108a02:	c9                   	leave  
80108a03:	c3                   	ret    

80108a04 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108a04:	55                   	push   %ebp
80108a05:	89 e5                	mov    %esp,%ebp
80108a07:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108a0a:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a0d:	c1 e8 16             	shr    $0x16,%eax
80108a10:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108a17:	8b 45 08             	mov    0x8(%ebp),%eax
80108a1a:	01 d0                	add    %edx,%eax
80108a1c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108a1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a22:	8b 00                	mov    (%eax),%eax
80108a24:	83 e0 01             	and    $0x1,%eax
80108a27:	85 c0                	test   %eax,%eax
80108a29:	74 14                	je     80108a3f <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80108a2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a2e:	8b 00                	mov    (%eax),%eax
80108a30:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a35:	05 00 00 00 80       	add    $0x80000000,%eax
80108a3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108a3d:	eb 48                	jmp    80108a87 <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108a3f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108a43:	74 0e                	je     80108a53 <walkpgdir+0x4f>
80108a45:	e8 c7 a4 ff ff       	call   80102f11 <kalloc>
80108a4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108a4d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108a51:	75 07                	jne    80108a5a <walkpgdir+0x56>
      return 0;
80108a53:	b8 00 00 00 00       	mov    $0x0,%eax
80108a58:	eb 44                	jmp    80108a9e <walkpgdir+0x9a>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108a5a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108a61:	00 
80108a62:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108a69:	00 
80108a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a6d:	89 04 24             	mov    %eax,(%esp)
80108a70:	e8 b5 cf ff ff       	call   80105a2a <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80108a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a78:	05 00 00 00 80       	add    $0x80000000,%eax
80108a7d:	83 c8 07             	or     $0x7,%eax
80108a80:	89 c2                	mov    %eax,%edx
80108a82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a85:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108a87:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a8a:	c1 e8 0c             	shr    $0xc,%eax
80108a8d:	25 ff 03 00 00       	and    $0x3ff,%eax
80108a92:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108a99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a9c:	01 d0                	add    %edx,%eax
}
80108a9e:	c9                   	leave  
80108a9f:	c3                   	ret    

80108aa0 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108aa0:	55                   	push   %ebp
80108aa1:	89 e5                	mov    %esp,%ebp
80108aa3:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80108aa6:	8b 45 0c             	mov    0xc(%ebp),%eax
80108aa9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108aae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108ab1:	8b 55 0c             	mov    0xc(%ebp),%edx
80108ab4:	8b 45 10             	mov    0x10(%ebp),%eax
80108ab7:	01 d0                	add    %edx,%eax
80108ab9:	48                   	dec    %eax
80108aba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108abf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108ac2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80108ac9:	00 
80108aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108acd:	89 44 24 04          	mov    %eax,0x4(%esp)
80108ad1:	8b 45 08             	mov    0x8(%ebp),%eax
80108ad4:	89 04 24             	mov    %eax,(%esp)
80108ad7:	e8 28 ff ff ff       	call   80108a04 <walkpgdir>
80108adc:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108adf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108ae3:	75 07                	jne    80108aec <mappages+0x4c>
      return -1;
80108ae5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108aea:	eb 48                	jmp    80108b34 <mappages+0x94>
    if(*pte & PTE_P)
80108aec:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108aef:	8b 00                	mov    (%eax),%eax
80108af1:	83 e0 01             	and    $0x1,%eax
80108af4:	85 c0                	test   %eax,%eax
80108af6:	74 0c                	je     80108b04 <mappages+0x64>
      panic("remap");
80108af8:	c7 04 24 b4 a4 10 80 	movl   $0x8010a4b4,(%esp)
80108aff:	e8 50 7a ff ff       	call   80100554 <panic>
    *pte = pa | perm | PTE_P;
80108b04:	8b 45 18             	mov    0x18(%ebp),%eax
80108b07:	0b 45 14             	or     0x14(%ebp),%eax
80108b0a:	83 c8 01             	or     $0x1,%eax
80108b0d:	89 c2                	mov    %eax,%edx
80108b0f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b12:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108b14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b17:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108b1a:	75 08                	jne    80108b24 <mappages+0x84>
      break;
80108b1c:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108b1d:	b8 00 00 00 00       	mov    $0x0,%eax
80108b22:	eb 10                	jmp    80108b34 <mappages+0x94>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80108b24:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108b2b:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80108b32:	eb 8e                	jmp    80108ac2 <mappages+0x22>
  return 0;
}
80108b34:	c9                   	leave  
80108b35:	c3                   	ret    

80108b36 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108b36:	55                   	push   %ebp
80108b37:	89 e5                	mov    %esp,%ebp
80108b39:	53                   	push   %ebx
80108b3a:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108b3d:	e8 cf a3 ff ff       	call   80102f11 <kalloc>
80108b42:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108b45:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108b49:	75 0a                	jne    80108b55 <setupkvm+0x1f>
    return 0;
80108b4b:	b8 00 00 00 00       	mov    $0x0,%eax
80108b50:	e9 84 00 00 00       	jmp    80108bd9 <setupkvm+0xa3>
  memset(pgdir, 0, PGSIZE);
80108b55:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108b5c:	00 
80108b5d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108b64:	00 
80108b65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b68:	89 04 24             	mov    %eax,(%esp)
80108b6b:	e8 ba ce ff ff       	call   80105a2a <memset>
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108b70:	c7 45 f4 60 d5 10 80 	movl   $0x8010d560,-0xc(%ebp)
80108b77:	eb 54                	jmp    80108bcd <setupkvm+0x97>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b7c:	8b 48 0c             	mov    0xc(%eax),%ecx
80108b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b82:	8b 50 04             	mov    0x4(%eax),%edx
80108b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b88:	8b 58 08             	mov    0x8(%eax),%ebx
80108b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b8e:	8b 40 04             	mov    0x4(%eax),%eax
80108b91:	29 c3                	sub    %eax,%ebx
80108b93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b96:	8b 00                	mov    (%eax),%eax
80108b98:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80108b9c:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108ba0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108ba4:	89 44 24 04          	mov    %eax,0x4(%esp)
80108ba8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bab:	89 04 24             	mov    %eax,(%esp)
80108bae:	e8 ed fe ff ff       	call   80108aa0 <mappages>
80108bb3:	85 c0                	test   %eax,%eax
80108bb5:	79 12                	jns    80108bc9 <setupkvm+0x93>
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
80108bb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bba:	89 04 24             	mov    %eax,(%esp)
80108bbd:	e8 1a 05 00 00       	call   801090dc <freevm>
      return 0;
80108bc2:	b8 00 00 00 00       	mov    $0x0,%eax
80108bc7:	eb 10                	jmp    80108bd9 <setupkvm+0xa3>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108bc9:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108bcd:	81 7d f4 a0 d5 10 80 	cmpl   $0x8010d5a0,-0xc(%ebp)
80108bd4:	72 a3                	jb     80108b79 <setupkvm+0x43>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
    }
  return pgdir;
80108bd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108bd9:	83 c4 34             	add    $0x34,%esp
80108bdc:	5b                   	pop    %ebx
80108bdd:	5d                   	pop    %ebp
80108bde:	c3                   	ret    

80108bdf <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108bdf:	55                   	push   %ebp
80108be0:	89 e5                	mov    %esp,%ebp
80108be2:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108be5:	e8 4c ff ff ff       	call   80108b36 <setupkvm>
80108bea:	a3 44 8d 11 80       	mov    %eax,0x80118d44
  switchkvm();
80108bef:	e8 02 00 00 00       	call   80108bf6 <switchkvm>
}
80108bf4:	c9                   	leave  
80108bf5:	c3                   	ret    

80108bf6 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108bf6:	55                   	push   %ebp
80108bf7:	89 e5                	mov    %esp,%ebp
80108bf9:	83 ec 04             	sub    $0x4,%esp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80108bfc:	a1 44 8d 11 80       	mov    0x80118d44,%eax
80108c01:	05 00 00 00 80       	add    $0x80000000,%eax
80108c06:	89 04 24             	mov    %eax,(%esp)
80108c09:	e8 ae fa ff ff       	call   801086bc <lcr3>
}
80108c0e:	c9                   	leave  
80108c0f:	c3                   	ret    

80108c10 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108c10:	55                   	push   %ebp
80108c11:	89 e5                	mov    %esp,%ebp
80108c13:	57                   	push   %edi
80108c14:	56                   	push   %esi
80108c15:	53                   	push   %ebx
80108c16:	83 ec 1c             	sub    $0x1c,%esp
  if(p == 0)
80108c19:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108c1d:	75 0c                	jne    80108c2b <switchuvm+0x1b>
    panic("switchuvm: no process");
80108c1f:	c7 04 24 ba a4 10 80 	movl   $0x8010a4ba,(%esp)
80108c26:	e8 29 79 ff ff       	call   80100554 <panic>
  if(p->kstack == 0)
80108c2b:	8b 45 08             	mov    0x8(%ebp),%eax
80108c2e:	8b 40 08             	mov    0x8(%eax),%eax
80108c31:	85 c0                	test   %eax,%eax
80108c33:	75 0c                	jne    80108c41 <switchuvm+0x31>
    panic("switchuvm: no kstack");
80108c35:	c7 04 24 d0 a4 10 80 	movl   $0x8010a4d0,(%esp)
80108c3c:	e8 13 79 ff ff       	call   80100554 <panic>
  if(p->pgdir == 0)
80108c41:	8b 45 08             	mov    0x8(%ebp),%eax
80108c44:	8b 40 04             	mov    0x4(%eax),%eax
80108c47:	85 c0                	test   %eax,%eax
80108c49:	75 0c                	jne    80108c57 <switchuvm+0x47>
    panic("switchuvm: no pgdir");
80108c4b:	c7 04 24 e5 a4 10 80 	movl   $0x8010a4e5,(%esp)
80108c52:	e8 fd 78 ff ff       	call   80100554 <panic>

  pushcli();
80108c57:	e8 ca cc ff ff       	call   80105926 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80108c5c:	e8 c2 b8 ff ff       	call   80104523 <mycpu>
80108c61:	89 c3                	mov    %eax,%ebx
80108c63:	e8 bb b8 ff ff       	call   80104523 <mycpu>
80108c68:	83 c0 08             	add    $0x8,%eax
80108c6b:	89 c6                	mov    %eax,%esi
80108c6d:	e8 b1 b8 ff ff       	call   80104523 <mycpu>
80108c72:	83 c0 08             	add    $0x8,%eax
80108c75:	c1 e8 10             	shr    $0x10,%eax
80108c78:	89 c7                	mov    %eax,%edi
80108c7a:	e8 a4 b8 ff ff       	call   80104523 <mycpu>
80108c7f:	83 c0 08             	add    $0x8,%eax
80108c82:	c1 e8 18             	shr    $0x18,%eax
80108c85:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80108c8c:	67 00 
80108c8e:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80108c95:	89 f9                	mov    %edi,%ecx
80108c97:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80108c9d:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108ca3:	83 e2 f0             	and    $0xfffffff0,%edx
80108ca6:	83 ca 09             	or     $0x9,%edx
80108ca9:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108caf:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108cb5:	83 ca 10             	or     $0x10,%edx
80108cb8:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108cbe:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108cc4:	83 e2 9f             	and    $0xffffff9f,%edx
80108cc7:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108ccd:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108cd3:	83 ca 80             	or     $0xffffff80,%edx
80108cd6:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108cdc:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108ce2:	83 e2 f0             	and    $0xfffffff0,%edx
80108ce5:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108ceb:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108cf1:	83 e2 ef             	and    $0xffffffef,%edx
80108cf4:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108cfa:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108d00:	83 e2 df             	and    $0xffffffdf,%edx
80108d03:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108d09:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108d0f:	83 ca 40             	or     $0x40,%edx
80108d12:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108d18:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108d1e:	83 e2 7f             	and    $0x7f,%edx
80108d21:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108d27:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80108d2d:	e8 f1 b7 ff ff       	call   80104523 <mycpu>
80108d32:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
80108d38:	83 e2 ef             	and    $0xffffffef,%edx
80108d3b:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80108d41:	e8 dd b7 ff ff       	call   80104523 <mycpu>
80108d46:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80108d4c:	e8 d2 b7 ff ff       	call   80104523 <mycpu>
80108d51:	8b 55 08             	mov    0x8(%ebp),%edx
80108d54:	8b 52 08             	mov    0x8(%edx),%edx
80108d57:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108d5d:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80108d60:	e8 be b7 ff ff       	call   80104523 <mycpu>
80108d65:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80108d6b:	c7 04 24 28 00 00 00 	movl   $0x28,(%esp)
80108d72:	e8 30 f9 ff ff       	call   801086a7 <ltr>
  lcr3(V2P(p->pgdir));  // switch to process's address space
80108d77:	8b 45 08             	mov    0x8(%ebp),%eax
80108d7a:	8b 40 04             	mov    0x4(%eax),%eax
80108d7d:	05 00 00 00 80       	add    $0x80000000,%eax
80108d82:	89 04 24             	mov    %eax,(%esp)
80108d85:	e8 32 f9 ff ff       	call   801086bc <lcr3>
  popcli();
80108d8a:	e8 e1 cb ff ff       	call   80105970 <popcli>
}
80108d8f:	83 c4 1c             	add    $0x1c,%esp
80108d92:	5b                   	pop    %ebx
80108d93:	5e                   	pop    %esi
80108d94:	5f                   	pop    %edi
80108d95:	5d                   	pop    %ebp
80108d96:	c3                   	ret    

80108d97 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108d97:	55                   	push   %ebp
80108d98:	89 e5                	mov    %esp,%ebp
80108d9a:	83 ec 38             	sub    $0x38,%esp
  char *mem;

  if(sz >= PGSIZE)
80108d9d:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108da4:	76 0c                	jbe    80108db2 <inituvm+0x1b>
    panic("inituvm: more than a page");
80108da6:	c7 04 24 f9 a4 10 80 	movl   $0x8010a4f9,(%esp)
80108dad:	e8 a2 77 ff ff       	call   80100554 <panic>
  mem = kalloc();
80108db2:	e8 5a a1 ff ff       	call   80102f11 <kalloc>
80108db7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108dba:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108dc1:	00 
80108dc2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108dc9:	00 
80108dca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dcd:	89 04 24             	mov    %eax,(%esp)
80108dd0:	e8 55 cc ff ff       	call   80105a2a <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80108dd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dd8:	05 00 00 00 80       	add    $0x80000000,%eax
80108ddd:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108de4:	00 
80108de5:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108de9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108df0:	00 
80108df1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108df8:	00 
80108df9:	8b 45 08             	mov    0x8(%ebp),%eax
80108dfc:	89 04 24             	mov    %eax,(%esp)
80108dff:	e8 9c fc ff ff       	call   80108aa0 <mappages>
  memmove(mem, init, sz);
80108e04:	8b 45 10             	mov    0x10(%ebp),%eax
80108e07:	89 44 24 08          	mov    %eax,0x8(%esp)
80108e0b:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e0e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108e12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e15:	89 04 24             	mov    %eax,(%esp)
80108e18:	e8 d6 cc ff ff       	call   80105af3 <memmove>
}
80108e1d:	c9                   	leave  
80108e1e:	c3                   	ret    

80108e1f <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108e1f:	55                   	push   %ebp
80108e20:	89 e5                	mov    %esp,%ebp
80108e22:	83 ec 28             	sub    $0x28,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108e25:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e28:	25 ff 0f 00 00       	and    $0xfff,%eax
80108e2d:	85 c0                	test   %eax,%eax
80108e2f:	74 0c                	je     80108e3d <loaduvm+0x1e>
    panic("loaduvm: addr must be page aligned");
80108e31:	c7 04 24 14 a5 10 80 	movl   $0x8010a514,(%esp)
80108e38:	e8 17 77 ff ff       	call   80100554 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108e3d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108e44:	e9 a6 00 00 00       	jmp    80108eef <loaduvm+0xd0>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108e49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e4c:	8b 55 0c             	mov    0xc(%ebp),%edx
80108e4f:	01 d0                	add    %edx,%eax
80108e51:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108e58:	00 
80108e59:	89 44 24 04          	mov    %eax,0x4(%esp)
80108e5d:	8b 45 08             	mov    0x8(%ebp),%eax
80108e60:	89 04 24             	mov    %eax,(%esp)
80108e63:	e8 9c fb ff ff       	call   80108a04 <walkpgdir>
80108e68:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108e6b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108e6f:	75 0c                	jne    80108e7d <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80108e71:	c7 04 24 37 a5 10 80 	movl   $0x8010a537,(%esp)
80108e78:	e8 d7 76 ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80108e7d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e80:	8b 00                	mov    (%eax),%eax
80108e82:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108e87:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e8d:	8b 55 18             	mov    0x18(%ebp),%edx
80108e90:	29 c2                	sub    %eax,%edx
80108e92:	89 d0                	mov    %edx,%eax
80108e94:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108e99:	77 0f                	ja     80108eaa <loaduvm+0x8b>
      n = sz - i;
80108e9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e9e:	8b 55 18             	mov    0x18(%ebp),%edx
80108ea1:	29 c2                	sub    %eax,%edx
80108ea3:	89 d0                	mov    %edx,%eax
80108ea5:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108ea8:	eb 07                	jmp    80108eb1 <loaduvm+0x92>
    else
      n = PGSIZE;
80108eaa:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80108eb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108eb4:	8b 55 14             	mov    0x14(%ebp),%edx
80108eb7:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80108eba:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ebd:	05 00 00 00 80       	add    $0x80000000,%eax
80108ec2:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108ec5:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108ec9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80108ecd:	89 44 24 04          	mov    %eax,0x4(%esp)
80108ed1:	8b 45 10             	mov    0x10(%ebp),%eax
80108ed4:	89 04 24             	mov    %eax,(%esp)
80108ed7:	e8 e2 90 ff ff       	call   80101fbe <readi>
80108edc:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108edf:	74 07                	je     80108ee8 <loaduvm+0xc9>
      return -1;
80108ee1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108ee6:	eb 18                	jmp    80108f00 <loaduvm+0xe1>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108ee8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108eef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ef2:	3b 45 18             	cmp    0x18(%ebp),%eax
80108ef5:	0f 82 4e ff ff ff    	jb     80108e49 <loaduvm+0x2a>
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108efb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108f00:	c9                   	leave  
80108f01:	c3                   	ret    

80108f02 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108f02:	55                   	push   %ebp
80108f03:	89 e5                	mov    %esp,%ebp
80108f05:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108f08:	8b 45 10             	mov    0x10(%ebp),%eax
80108f0b:	85 c0                	test   %eax,%eax
80108f0d:	79 0a                	jns    80108f19 <allocuvm+0x17>
    return 0;
80108f0f:	b8 00 00 00 00       	mov    $0x0,%eax
80108f14:	e9 fd 00 00 00       	jmp    80109016 <allocuvm+0x114>
  if(newsz < oldsz)
80108f19:	8b 45 10             	mov    0x10(%ebp),%eax
80108f1c:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108f1f:	73 08                	jae    80108f29 <allocuvm+0x27>
    return oldsz;
80108f21:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f24:	e9 ed 00 00 00       	jmp    80109016 <allocuvm+0x114>

  a = PGROUNDUP(oldsz);
80108f29:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f2c:	05 ff 0f 00 00       	add    $0xfff,%eax
80108f31:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f36:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108f39:	e9 c9 00 00 00       	jmp    80109007 <allocuvm+0x105>
    mem = kalloc();
80108f3e:	e8 ce 9f ff ff       	call   80102f11 <kalloc>
80108f43:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108f46:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108f4a:	75 2f                	jne    80108f7b <allocuvm+0x79>
      cprintf("allocuvm out of memory\n");
80108f4c:	c7 04 24 55 a5 10 80 	movl   $0x8010a555,(%esp)
80108f53:	e8 69 74 ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108f58:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f5b:	89 44 24 08          	mov    %eax,0x8(%esp)
80108f5f:	8b 45 10             	mov    0x10(%ebp),%eax
80108f62:	89 44 24 04          	mov    %eax,0x4(%esp)
80108f66:	8b 45 08             	mov    0x8(%ebp),%eax
80108f69:	89 04 24             	mov    %eax,(%esp)
80108f6c:	e8 a7 00 00 00       	call   80109018 <deallocuvm>
      return 0;
80108f71:	b8 00 00 00 00       	mov    $0x0,%eax
80108f76:	e9 9b 00 00 00       	jmp    80109016 <allocuvm+0x114>
    }
    memset(mem, 0, PGSIZE);
80108f7b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108f82:	00 
80108f83:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108f8a:	00 
80108f8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f8e:	89 04 24             	mov    %eax,(%esp)
80108f91:	e8 94 ca ff ff       	call   80105a2a <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80108f96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f99:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108f9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fa2:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108fa9:	00 
80108faa:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108fae:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108fb5:	00 
80108fb6:	89 44 24 04          	mov    %eax,0x4(%esp)
80108fba:	8b 45 08             	mov    0x8(%ebp),%eax
80108fbd:	89 04 24             	mov    %eax,(%esp)
80108fc0:	e8 db fa ff ff       	call   80108aa0 <mappages>
80108fc5:	85 c0                	test   %eax,%eax
80108fc7:	79 37                	jns    80109000 <allocuvm+0xfe>
      cprintf("allocuvm out of memory (2)\n");
80108fc9:	c7 04 24 6d a5 10 80 	movl   $0x8010a56d,(%esp)
80108fd0:	e8 ec 73 ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108fd5:	8b 45 0c             	mov    0xc(%ebp),%eax
80108fd8:	89 44 24 08          	mov    %eax,0x8(%esp)
80108fdc:	8b 45 10             	mov    0x10(%ebp),%eax
80108fdf:	89 44 24 04          	mov    %eax,0x4(%esp)
80108fe3:	8b 45 08             	mov    0x8(%ebp),%eax
80108fe6:	89 04 24             	mov    %eax,(%esp)
80108fe9:	e8 2a 00 00 00       	call   80109018 <deallocuvm>
      kfree(mem);
80108fee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ff1:	89 04 24             	mov    %eax,(%esp)
80108ff4:	e8 2a 9e ff ff       	call   80102e23 <kfree>
      return 0;
80108ff9:	b8 00 00 00 00       	mov    $0x0,%eax
80108ffe:	eb 16                	jmp    80109016 <allocuvm+0x114>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80109000:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109007:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010900a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010900d:	0f 82 2b ff ff ff    	jb     80108f3e <allocuvm+0x3c>
      deallocuvm(pgdir, newsz, oldsz);
      kfree(mem);
      return 0;
    }
  }
  return newsz;
80109013:	8b 45 10             	mov    0x10(%ebp),%eax
}
80109016:	c9                   	leave  
80109017:	c3                   	ret    

80109018 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80109018:	55                   	push   %ebp
80109019:	89 e5                	mov    %esp,%ebp
8010901b:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
8010901e:	8b 45 10             	mov    0x10(%ebp),%eax
80109021:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109024:	72 08                	jb     8010902e <deallocuvm+0x16>
    return oldsz;
80109026:	8b 45 0c             	mov    0xc(%ebp),%eax
80109029:	e9 ac 00 00 00       	jmp    801090da <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
8010902e:	8b 45 10             	mov    0x10(%ebp),%eax
80109031:	05 ff 0f 00 00       	add    $0xfff,%eax
80109036:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010903b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010903e:	e9 88 00 00 00       	jmp    801090cb <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80109043:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109046:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010904d:	00 
8010904e:	89 44 24 04          	mov    %eax,0x4(%esp)
80109052:	8b 45 08             	mov    0x8(%ebp),%eax
80109055:	89 04 24             	mov    %eax,(%esp)
80109058:	e8 a7 f9 ff ff       	call   80108a04 <walkpgdir>
8010905d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80109060:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109064:	75 14                	jne    8010907a <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80109066:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109069:	c1 e8 16             	shr    $0x16,%eax
8010906c:	40                   	inc    %eax
8010906d:	c1 e0 16             	shl    $0x16,%eax
80109070:	2d 00 10 00 00       	sub    $0x1000,%eax
80109075:	89 45 f4             	mov    %eax,-0xc(%ebp)
80109078:	eb 4a                	jmp    801090c4 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
8010907a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010907d:	8b 00                	mov    (%eax),%eax
8010907f:	83 e0 01             	and    $0x1,%eax
80109082:	85 c0                	test   %eax,%eax
80109084:	74 3e                	je     801090c4 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80109086:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109089:	8b 00                	mov    (%eax),%eax
8010908b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109090:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80109093:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109097:	75 0c                	jne    801090a5 <deallocuvm+0x8d>
        panic("kfree");
80109099:	c7 04 24 89 a5 10 80 	movl   $0x8010a589,(%esp)
801090a0:	e8 af 74 ff ff       	call   80100554 <panic>
      char *v = P2V(pa);
801090a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090a8:	05 00 00 00 80       	add    $0x80000000,%eax
801090ad:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801090b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090b3:	89 04 24             	mov    %eax,(%esp)
801090b6:	e8 68 9d ff ff       	call   80102e23 <kfree>
      *pte = 0;
801090bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090be:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801090c4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801090cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090ce:	3b 45 0c             	cmp    0xc(%ebp),%eax
801090d1:	0f 82 6c ff ff ff    	jb     80109043 <deallocuvm+0x2b>
      char *v = P2V(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
801090d7:	8b 45 10             	mov    0x10(%ebp),%eax
}
801090da:	c9                   	leave  
801090db:	c3                   	ret    

801090dc <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801090dc:	55                   	push   %ebp
801090dd:	89 e5                	mov    %esp,%ebp
801090df:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
801090e2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801090e6:	75 0c                	jne    801090f4 <freevm+0x18>
    panic("freevm: no pgdir");
801090e8:	c7 04 24 8f a5 10 80 	movl   $0x8010a58f,(%esp)
801090ef:	e8 60 74 ff ff       	call   80100554 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801090f4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801090fb:	00 
801090fc:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80109103:	80 
80109104:	8b 45 08             	mov    0x8(%ebp),%eax
80109107:	89 04 24             	mov    %eax,(%esp)
8010910a:	e8 09 ff ff ff       	call   80109018 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
8010910f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109116:	eb 44                	jmp    8010915c <freevm+0x80>
    if(pgdir[i] & PTE_P){
80109118:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010911b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109122:	8b 45 08             	mov    0x8(%ebp),%eax
80109125:	01 d0                	add    %edx,%eax
80109127:	8b 00                	mov    (%eax),%eax
80109129:	83 e0 01             	and    $0x1,%eax
8010912c:	85 c0                	test   %eax,%eax
8010912e:	74 29                	je     80109159 <freevm+0x7d>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80109130:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109133:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010913a:	8b 45 08             	mov    0x8(%ebp),%eax
8010913d:	01 d0                	add    %edx,%eax
8010913f:	8b 00                	mov    (%eax),%eax
80109141:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109146:	05 00 00 00 80       	add    $0x80000000,%eax
8010914b:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010914e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109151:	89 04 24             	mov    %eax,(%esp)
80109154:	e8 ca 9c ff ff       	call   80102e23 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80109159:	ff 45 f4             	incl   -0xc(%ebp)
8010915c:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80109163:	76 b3                	jbe    80109118 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80109165:	8b 45 08             	mov    0x8(%ebp),%eax
80109168:	89 04 24             	mov    %eax,(%esp)
8010916b:	e8 b3 9c ff ff       	call   80102e23 <kfree>
}
80109170:	c9                   	leave  
80109171:	c3                   	ret    

80109172 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80109172:	55                   	push   %ebp
80109173:	89 e5                	mov    %esp,%ebp
80109175:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109178:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010917f:	00 
80109180:	8b 45 0c             	mov    0xc(%ebp),%eax
80109183:	89 44 24 04          	mov    %eax,0x4(%esp)
80109187:	8b 45 08             	mov    0x8(%ebp),%eax
8010918a:	89 04 24             	mov    %eax,(%esp)
8010918d:	e8 72 f8 ff ff       	call   80108a04 <walkpgdir>
80109192:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80109195:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109199:	75 0c                	jne    801091a7 <clearpteu+0x35>
    panic("clearpteu");
8010919b:	c7 04 24 a0 a5 10 80 	movl   $0x8010a5a0,(%esp)
801091a2:	e8 ad 73 ff ff       	call   80100554 <panic>
  *pte &= ~PTE_U;
801091a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091aa:	8b 00                	mov    (%eax),%eax
801091ac:	83 e0 fb             	and    $0xfffffffb,%eax
801091af:	89 c2                	mov    %eax,%edx
801091b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091b4:	89 10                	mov    %edx,(%eax)
}
801091b6:	c9                   	leave  
801091b7:	c3                   	ret    

801091b8 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801091b8:	55                   	push   %ebp
801091b9:	89 e5                	mov    %esp,%ebp
801091bb:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801091be:	e8 73 f9 ff ff       	call   80108b36 <setupkvm>
801091c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801091c6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801091ca:	75 0a                	jne    801091d6 <copyuvm+0x1e>
    return 0;
801091cc:	b8 00 00 00 00       	mov    $0x0,%eax
801091d1:	e9 f8 00 00 00       	jmp    801092ce <copyuvm+0x116>
  for(i = 0; i < sz; i += PGSIZE){
801091d6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801091dd:	e9 cb 00 00 00       	jmp    801092ad <copyuvm+0xf5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801091e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091e5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801091ec:	00 
801091ed:	89 44 24 04          	mov    %eax,0x4(%esp)
801091f1:	8b 45 08             	mov    0x8(%ebp),%eax
801091f4:	89 04 24             	mov    %eax,(%esp)
801091f7:	e8 08 f8 ff ff       	call   80108a04 <walkpgdir>
801091fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
801091ff:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109203:	75 0c                	jne    80109211 <copyuvm+0x59>
      panic("copyuvm: pte should exist");
80109205:	c7 04 24 aa a5 10 80 	movl   $0x8010a5aa,(%esp)
8010920c:	e8 43 73 ff ff       	call   80100554 <panic>
    if(!(*pte & PTE_P))
80109211:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109214:	8b 00                	mov    (%eax),%eax
80109216:	83 e0 01             	and    $0x1,%eax
80109219:	85 c0                	test   %eax,%eax
8010921b:	75 0c                	jne    80109229 <copyuvm+0x71>
      panic("copyuvm: page not present");
8010921d:	c7 04 24 c4 a5 10 80 	movl   $0x8010a5c4,(%esp)
80109224:	e8 2b 73 ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80109229:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010922c:	8b 00                	mov    (%eax),%eax
8010922e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109233:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80109236:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109239:	8b 00                	mov    (%eax),%eax
8010923b:	25 ff 0f 00 00       	and    $0xfff,%eax
80109240:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80109243:	e8 c9 9c ff ff       	call   80102f11 <kalloc>
80109248:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010924b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010924f:	75 02                	jne    80109253 <copyuvm+0x9b>
      goto bad;
80109251:	eb 6b                	jmp    801092be <copyuvm+0x106>
    memmove(mem, (char*)P2V(pa), PGSIZE);
80109253:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109256:	05 00 00 00 80       	add    $0x80000000,%eax
8010925b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80109262:	00 
80109263:	89 44 24 04          	mov    %eax,0x4(%esp)
80109267:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010926a:	89 04 24             	mov    %eax,(%esp)
8010926d:	e8 81 c8 ff ff       	call   80105af3 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80109272:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109275:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109278:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
8010927e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109281:	89 54 24 10          	mov    %edx,0x10(%esp)
80109285:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80109289:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80109290:	00 
80109291:	89 44 24 04          	mov    %eax,0x4(%esp)
80109295:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109298:	89 04 24             	mov    %eax,(%esp)
8010929b:	e8 00 f8 ff ff       	call   80108aa0 <mappages>
801092a0:	85 c0                	test   %eax,%eax
801092a2:	79 02                	jns    801092a6 <copyuvm+0xee>
      goto bad;
801092a4:	eb 18                	jmp    801092be <copyuvm+0x106>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801092a6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801092ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092b0:	3b 45 0c             	cmp    0xc(%ebp),%eax
801092b3:	0f 82 29 ff ff ff    	jb     801091e2 <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }
  return d;
801092b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092bc:	eb 10                	jmp    801092ce <copyuvm+0x116>

bad:
  freevm(d);
801092be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092c1:	89 04 24             	mov    %eax,(%esp)
801092c4:	e8 13 fe ff ff       	call   801090dc <freevm>
  return 0;
801092c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801092ce:	c9                   	leave  
801092cf:	c3                   	ret    

801092d0 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801092d0:	55                   	push   %ebp
801092d1:	89 e5                	mov    %esp,%ebp
801092d3:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801092d6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801092dd:	00 
801092de:	8b 45 0c             	mov    0xc(%ebp),%eax
801092e1:	89 44 24 04          	mov    %eax,0x4(%esp)
801092e5:	8b 45 08             	mov    0x8(%ebp),%eax
801092e8:	89 04 24             	mov    %eax,(%esp)
801092eb:	e8 14 f7 ff ff       	call   80108a04 <walkpgdir>
801092f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801092f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092f6:	8b 00                	mov    (%eax),%eax
801092f8:	83 e0 01             	and    $0x1,%eax
801092fb:	85 c0                	test   %eax,%eax
801092fd:	75 07                	jne    80109306 <uva2ka+0x36>
    return 0;
801092ff:	b8 00 00 00 00       	mov    $0x0,%eax
80109304:	eb 22                	jmp    80109328 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80109306:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109309:	8b 00                	mov    (%eax),%eax
8010930b:	83 e0 04             	and    $0x4,%eax
8010930e:	85 c0                	test   %eax,%eax
80109310:	75 07                	jne    80109319 <uva2ka+0x49>
    return 0;
80109312:	b8 00 00 00 00       	mov    $0x0,%eax
80109317:	eb 0f                	jmp    80109328 <uva2ka+0x58>
  return (char*)P2V(PTE_ADDR(*pte));
80109319:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010931c:	8b 00                	mov    (%eax),%eax
8010931e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109323:	05 00 00 00 80       	add    $0x80000000,%eax
}
80109328:	c9                   	leave  
80109329:	c3                   	ret    

8010932a <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010932a:	55                   	push   %ebp
8010932b:	89 e5                	mov    %esp,%ebp
8010932d:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80109330:	8b 45 10             	mov    0x10(%ebp),%eax
80109333:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80109336:	e9 87 00 00 00       	jmp    801093c2 <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
8010933b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010933e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109343:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80109346:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109349:	89 44 24 04          	mov    %eax,0x4(%esp)
8010934d:	8b 45 08             	mov    0x8(%ebp),%eax
80109350:	89 04 24             	mov    %eax,(%esp)
80109353:	e8 78 ff ff ff       	call   801092d0 <uva2ka>
80109358:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010935b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010935f:	75 07                	jne    80109368 <copyout+0x3e>
      return -1;
80109361:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109366:	eb 69                	jmp    801093d1 <copyout+0xa7>
    n = PGSIZE - (va - va0);
80109368:	8b 45 0c             	mov    0xc(%ebp),%eax
8010936b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010936e:	29 c2                	sub    %eax,%edx
80109370:	89 d0                	mov    %edx,%eax
80109372:	05 00 10 00 00       	add    $0x1000,%eax
80109377:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010937a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010937d:	3b 45 14             	cmp    0x14(%ebp),%eax
80109380:	76 06                	jbe    80109388 <copyout+0x5e>
      n = len;
80109382:	8b 45 14             	mov    0x14(%ebp),%eax
80109385:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80109388:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010938b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010938e:	29 c2                	sub    %eax,%edx
80109390:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109393:	01 c2                	add    %eax,%edx
80109395:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109398:	89 44 24 08          	mov    %eax,0x8(%esp)
8010939c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010939f:	89 44 24 04          	mov    %eax,0x4(%esp)
801093a3:	89 14 24             	mov    %edx,(%esp)
801093a6:	e8 48 c7 ff ff       	call   80105af3 <memmove>
    len -= n;
801093ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093ae:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801093b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093b4:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801093b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801093ba:	05 00 10 00 00       	add    $0x1000,%eax
801093bf:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801093c2:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801093c6:	0f 85 6f ff ff ff    	jne    8010933b <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801093cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801093d1:	c9                   	leave  
801093d2:	c3                   	ret    
	...

801093d4 <memcpy2>:

struct container containers[MAX_CONTAINERS];

void*
memcpy2(void *dst, const void *src, uint n)
{
801093d4:	55                   	push   %ebp
801093d5:	89 e5                	mov    %esp,%ebp
801093d7:	83 ec 18             	sub    $0x18,%esp
  return memmove(dst, src, n);
801093da:	8b 45 10             	mov    0x10(%ebp),%eax
801093dd:	89 44 24 08          	mov    %eax,0x8(%esp)
801093e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801093e4:	89 44 24 04          	mov    %eax,0x4(%esp)
801093e8:	8b 45 08             	mov    0x8(%ebp),%eax
801093eb:	89 04 24             	mov    %eax,(%esp)
801093ee:	e8 00 c7 ff ff       	call   80105af3 <memmove>
}
801093f3:	c9                   	leave  
801093f4:	c3                   	ret    

801093f5 <strcpy>:

char* strcpy(char *s, char *t){
801093f5:	55                   	push   %ebp
801093f6:	89 e5                	mov    %esp,%ebp
801093f8:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801093fb:	8b 45 08             	mov    0x8(%ebp),%eax
801093fe:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
80109401:	90                   	nop
80109402:	8b 45 08             	mov    0x8(%ebp),%eax
80109405:	8d 50 01             	lea    0x1(%eax),%edx
80109408:	89 55 08             	mov    %edx,0x8(%ebp)
8010940b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010940e:	8d 4a 01             	lea    0x1(%edx),%ecx
80109411:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80109414:	8a 12                	mov    (%edx),%dl
80109416:	88 10                	mov    %dl,(%eax)
80109418:	8a 00                	mov    (%eax),%al
8010941a:	84 c0                	test   %al,%al
8010941c:	75 e4                	jne    80109402 <strcpy+0xd>
    ;
  return os;
8010941e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80109421:	c9                   	leave  
80109422:	c3                   	ret    

80109423 <strcmp>:

int
strcmp(const char *p, const char *q)
{
80109423:	55                   	push   %ebp
80109424:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
80109426:	eb 06                	jmp    8010942e <strcmp+0xb>
    p++, q++;
80109428:	ff 45 08             	incl   0x8(%ebp)
8010942b:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
8010942e:	8b 45 08             	mov    0x8(%ebp),%eax
80109431:	8a 00                	mov    (%eax),%al
80109433:	84 c0                	test   %al,%al
80109435:	74 0e                	je     80109445 <strcmp+0x22>
80109437:	8b 45 08             	mov    0x8(%ebp),%eax
8010943a:	8a 10                	mov    (%eax),%dl
8010943c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010943f:	8a 00                	mov    (%eax),%al
80109441:	38 c2                	cmp    %al,%dl
80109443:	74 e3                	je     80109428 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
80109445:	8b 45 08             	mov    0x8(%ebp),%eax
80109448:	8a 00                	mov    (%eax),%al
8010944a:	0f b6 d0             	movzbl %al,%edx
8010944d:	8b 45 0c             	mov    0xc(%ebp),%eax
80109450:	8a 00                	mov    (%eax),%al
80109452:	0f b6 c0             	movzbl %al,%eax
80109455:	29 c2                	sub    %eax,%edx
80109457:	89 d0                	mov    %edx,%eax
}
80109459:	5d                   	pop    %ebp
8010945a:	c3                   	ret    

8010945b <set_root_inode>:

// struct con

void set_root_inode(char* name){
8010945b:	55                   	push   %ebp
8010945c:	89 e5                	mov    %esp,%ebp
8010945e:	53                   	push   %ebx
8010945f:	83 ec 14             	sub    $0x14,%esp

	containers[find(name)].root = namei(name);
80109462:	8b 45 08             	mov    0x8(%ebp),%eax
80109465:	89 04 24             	mov    %eax,(%esp)
80109468:	e8 44 01 00 00       	call   801095b1 <find>
8010946d:	89 c3                	mov    %eax,%ebx
8010946f:	8b 45 08             	mov    0x8(%ebp),%eax
80109472:	89 04 24             	mov    %eax,(%esp)
80109475:	e8 28 93 ff ff       	call   801027a2 <namei>
8010947a:	89 c2                	mov    %eax,%edx
8010947c:	89 d8                	mov    %ebx,%eax
8010947e:	c1 e0 02             	shl    $0x2,%eax
80109481:	89 c1                	mov    %eax,%ecx
80109483:	c1 e1 04             	shl    $0x4,%ecx
80109486:	01 c8                	add    %ecx,%eax
80109488:	05 90 8d 11 80       	add    $0x80118d90,%eax
8010948d:	89 50 0c             	mov    %edx,0xc(%eax)

}
80109490:	83 c4 14             	add    $0x14,%esp
80109493:	5b                   	pop    %ebx
80109494:	5d                   	pop    %ebp
80109495:	c3                   	ret    

80109496 <get_name>:

void get_name(int vc_num, char* name){
80109496:	55                   	push   %ebp
80109497:	89 e5                	mov    %esp,%ebp
80109499:	83 ec 28             	sub    $0x28,%esp

	char* name2 = containers[vc_num].name;
8010949c:	8b 45 08             	mov    0x8(%ebp),%eax
8010949f:	c1 e0 02             	shl    $0x2,%eax
801094a2:	89 c2                	mov    %eax,%edx
801094a4:	c1 e2 04             	shl    $0x4,%edx
801094a7:	01 d0                	add    %edx,%eax
801094a9:	83 c0 10             	add    $0x10,%eax
801094ac:	05 60 8d 11 80       	add    $0x80118d60,%eax
801094b1:	83 c0 0c             	add    $0xc,%eax
801094b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i = 0;
801094b7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	while(name2[i])
801094be:	eb 03                	jmp    801094c3 <get_name+0x2d>
	{
		i++;
801094c0:	ff 45 f4             	incl   -0xc(%ebp)

void get_name(int vc_num, char* name){

	char* name2 = containers[vc_num].name;
	int i = 0;
	while(name2[i])
801094c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801094c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094c9:	01 d0                	add    %edx,%eax
801094cb:	8a 00                	mov    (%eax),%al
801094cd:	84 c0                	test   %al,%al
801094cf:	75 ef                	jne    801094c0 <get_name+0x2a>
	{
		i++;
	}
	memcpy2(name, name2, i);
801094d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094d4:	89 44 24 08          	mov    %eax,0x8(%esp)
801094d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094db:	89 44 24 04          	mov    %eax,0x4(%esp)
801094df:	8b 45 0c             	mov    0xc(%ebp),%eax
801094e2:	89 04 24             	mov    %eax,(%esp)
801094e5:	e8 ea fe ff ff       	call   801093d4 <memcpy2>
	name[i] = '\0';
801094ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
801094ed:	8b 45 0c             	mov    0xc(%ebp),%eax
801094f0:	01 d0                	add    %edx,%eax
801094f2:	c6 00 00             	movb   $0x0,(%eax)
}
801094f5:	c9                   	leave  
801094f6:	c3                   	ret    

801094f7 <get_used>:

int get_used(){
801094f7:	55                   	push   %ebp
801094f8:	89 e5                	mov    %esp,%ebp
801094fa:	83 ec 18             	sub    $0x18,%esp
	int x = 0;
801094fd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80109504:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010950b:	eb 34                	jmp    80109541 <get_used+0x4a>
		if(strcmp(containers[i].name, "") == 0){
8010950d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109510:	c1 e0 02             	shl    $0x2,%eax
80109513:	89 c2                	mov    %eax,%edx
80109515:	c1 e2 04             	shl    $0x4,%edx
80109518:	01 d0                	add    %edx,%eax
8010951a:	83 c0 10             	add    $0x10,%eax
8010951d:	05 60 8d 11 80       	add    $0x80118d60,%eax
80109522:	83 c0 0c             	add    $0xc,%eax
80109525:	c7 44 24 04 e0 a5 10 	movl   $0x8010a5e0,0x4(%esp)
8010952c:	80 
8010952d:	89 04 24             	mov    %eax,(%esp)
80109530:	e8 ee fe ff ff       	call   80109423 <strcmp>
80109535:	85 c0                	test   %eax,%eax
80109537:	75 02                	jne    8010953b <get_used+0x44>
			continue;
80109539:	eb 03                	jmp    8010953e <get_used+0x47>
		}
		x++;
8010953b:	ff 45 fc             	incl   -0x4(%ebp)
}

int get_used(){
	int x = 0;
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
8010953e:	ff 45 f8             	incl   -0x8(%ebp)
80109541:	83 7d f8 03          	cmpl   $0x3,-0x8(%ebp)
80109545:	7e c6                	jle    8010950d <get_used+0x16>
		if(strcmp(containers[i].name, "") == 0){
			continue;
		}
		x++;
	}
	return x;
80109547:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010954a:	c9                   	leave  
8010954b:	c3                   	ret    

8010954c <g_name>:

char* g_name(int vc_bun){
8010954c:	55                   	push   %ebp
8010954d:	89 e5                	mov    %esp,%ebp
	return containers[vc_bun].name;
8010954f:	8b 45 08             	mov    0x8(%ebp),%eax
80109552:	c1 e0 02             	shl    $0x2,%eax
80109555:	89 c2                	mov    %eax,%edx
80109557:	c1 e2 04             	shl    $0x4,%edx
8010955a:	01 d0                	add    %edx,%eax
8010955c:	83 c0 10             	add    $0x10,%eax
8010955f:	05 60 8d 11 80       	add    $0x80118d60,%eax
80109564:	83 c0 0c             	add    $0xc,%eax
}
80109567:	5d                   	pop    %ebp
80109568:	c3                   	ret    

80109569 <is_full>:

int is_full(){
80109569:	55                   	push   %ebp
8010956a:	89 e5                	mov    %esp,%ebp
8010956c:	83 ec 28             	sub    $0x28,%esp
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
8010956f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109576:	eb 2c                	jmp    801095a4 <is_full+0x3b>
		if(strlen(containers[i].name) == 0){
80109578:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010957b:	c1 e0 02             	shl    $0x2,%eax
8010957e:	89 c2                	mov    %eax,%edx
80109580:	c1 e2 04             	shl    $0x4,%edx
80109583:	01 d0                	add    %edx,%eax
80109585:	83 c0 10             	add    $0x10,%eax
80109588:	05 60 8d 11 80       	add    $0x80118d60,%eax
8010958d:	83 c0 0c             	add    $0xc,%eax
80109590:	89 04 24             	mov    %eax,(%esp)
80109593:	e8 e5 c6 ff ff       	call   80105c7d <strlen>
80109598:	85 c0                	test   %eax,%eax
8010959a:	75 05                	jne    801095a1 <is_full+0x38>
			return i;
8010959c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010959f:	eb 0e                	jmp    801095af <is_full+0x46>
	return containers[vc_bun].name;
}

int is_full(){
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
801095a1:	ff 45 f4             	incl   -0xc(%ebp)
801095a4:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
801095a8:	7e ce                	jle    80109578 <is_full+0xf>
		if(strlen(containers[i].name) == 0){
			return i;
		}
	}
	return -1;
801095aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801095af:	c9                   	leave  
801095b0:	c3                   	ret    

801095b1 <find>:

int find(char* name){
801095b1:	55                   	push   %ebp
801095b2:	89 e5                	mov    %esp,%ebp
801095b4:	83 ec 18             	sub    $0x18,%esp
	int i;

	for(i = 0; i < MAX_CONTAINERS; i++){
801095b7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801095be:	eb 4c                	jmp    8010960c <find+0x5b>
		if(strcmp(name, "") == 0){
801095c0:	c7 44 24 04 e0 a5 10 	movl   $0x8010a5e0,0x4(%esp)
801095c7:	80 
801095c8:	8b 45 08             	mov    0x8(%ebp),%eax
801095cb:	89 04 24             	mov    %eax,(%esp)
801095ce:	e8 50 fe ff ff       	call   80109423 <strcmp>
801095d3:	85 c0                	test   %eax,%eax
801095d5:	75 02                	jne    801095d9 <find+0x28>
			continue;
801095d7:	eb 30                	jmp    80109609 <find+0x58>
		}
		if(strcmp(name, containers[i].name) == 0){
801095d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801095dc:	c1 e0 02             	shl    $0x2,%eax
801095df:	89 c2                	mov    %eax,%edx
801095e1:	c1 e2 04             	shl    $0x4,%edx
801095e4:	01 d0                	add    %edx,%eax
801095e6:	83 c0 10             	add    $0x10,%eax
801095e9:	05 60 8d 11 80       	add    $0x80118d60,%eax
801095ee:	83 c0 0c             	add    $0xc,%eax
801095f1:	89 44 24 04          	mov    %eax,0x4(%esp)
801095f5:	8b 45 08             	mov    0x8(%ebp),%eax
801095f8:	89 04 24             	mov    %eax,(%esp)
801095fb:	e8 23 fe ff ff       	call   80109423 <strcmp>
80109600:	85 c0                	test   %eax,%eax
80109602:	75 05                	jne    80109609 <find+0x58>
			return i;
80109604:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109607:	eb 0e                	jmp    80109617 <find+0x66>
}

int find(char* name){
	int i;

	for(i = 0; i < MAX_CONTAINERS; i++){
80109609:	ff 45 fc             	incl   -0x4(%ebp)
8010960c:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
80109610:	7e ae                	jle    801095c0 <find+0xf>
		}
		if(strcmp(name, containers[i].name) == 0){
			return i;
		}
	}
	return -1;
80109612:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80109617:	c9                   	leave  
80109618:	c3                   	ret    

80109619 <get_max_proc>:

int get_max_proc(int vc_num){
80109619:	55                   	push   %ebp
8010961a:	89 e5                	mov    %esp,%ebp
8010961c:	57                   	push   %edi
8010961d:	56                   	push   %esi
8010961e:	53                   	push   %ebx
8010961f:	83 ec 50             	sub    $0x50,%esp
	struct container x = containers[vc_num];
80109622:	8b 45 08             	mov    0x8(%ebp),%eax
80109625:	c1 e0 02             	shl    $0x2,%eax
80109628:	89 c2                	mov    %eax,%edx
8010962a:	c1 e2 04             	shl    $0x4,%edx
8010962d:	01 d0                	add    %edx,%eax
8010962f:	05 60 8d 11 80       	add    $0x80118d60,%eax
80109634:	8d 55 b0             	lea    -0x50(%ebp),%edx
80109637:	89 c3                	mov    %eax,%ebx
80109639:	b8 11 00 00 00       	mov    $0x11,%eax
8010963e:	89 d7                	mov    %edx,%edi
80109640:	89 de                	mov    %ebx,%esi
80109642:	89 c1                	mov    %eax,%ecx
80109644:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_proc;
80109646:	8b 45 b4             	mov    -0x4c(%ebp),%eax
}
80109649:	83 c4 50             	add    $0x50,%esp
8010964c:	5b                   	pop    %ebx
8010964d:	5e                   	pop    %esi
8010964e:	5f                   	pop    %edi
8010964f:	5d                   	pop    %ebp
80109650:	c3                   	ret    

80109651 <get_os>:

int get_os(void){
80109651:	55                   	push   %ebp
80109652:	89 e5                	mov    %esp,%ebp
	return disk_used;
80109654:	a1 68 d9 10 80       	mov    0x8010d968,%eax
}
80109659:	5d                   	pop    %ebp
8010965a:	c3                   	ret    

8010965b <get_container>:

struct container* get_container(int vc_num){
8010965b:	55                   	push   %ebp
8010965c:	89 e5                	mov    %esp,%ebp
8010965e:	83 ec 10             	sub    $0x10,%esp
	struct container* cont = &containers[vc_num];
80109661:	8b 45 08             	mov    0x8(%ebp),%eax
80109664:	c1 e0 02             	shl    $0x2,%eax
80109667:	89 c2                	mov    %eax,%edx
80109669:	c1 e2 04             	shl    $0x4,%edx
8010966c:	01 d0                	add    %edx,%eax
8010966e:	05 60 8d 11 80       	add    $0x80118d60,%eax
80109673:	89 45 fc             	mov    %eax,-0x4(%ebp)
	return cont;
80109676:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80109679:	c9                   	leave  
8010967a:	c3                   	ret    

8010967b <get_max_mem>:

int get_max_mem(int vc_num){
8010967b:	55                   	push   %ebp
8010967c:	89 e5                	mov    %esp,%ebp
8010967e:	57                   	push   %edi
8010967f:	56                   	push   %esi
80109680:	53                   	push   %ebx
80109681:	83 ec 50             	sub    $0x50,%esp
	struct container x = containers[vc_num];
80109684:	8b 45 08             	mov    0x8(%ebp),%eax
80109687:	c1 e0 02             	shl    $0x2,%eax
8010968a:	89 c2                	mov    %eax,%edx
8010968c:	c1 e2 04             	shl    $0x4,%edx
8010968f:	01 d0                	add    %edx,%eax
80109691:	05 60 8d 11 80       	add    $0x80118d60,%eax
80109696:	8d 55 b0             	lea    -0x50(%ebp),%edx
80109699:	89 c3                	mov    %eax,%ebx
8010969b:	b8 11 00 00 00       	mov    $0x11,%eax
801096a0:	89 d7                	mov    %edx,%edi
801096a2:	89 de                	mov    %ebx,%esi
801096a4:	89 c1                	mov    %eax,%ecx
801096a6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_mem; 
801096a8:	8b 45 b0             	mov    -0x50(%ebp),%eax
}
801096ab:	83 c4 50             	add    $0x50,%esp
801096ae:	5b                   	pop    %ebx
801096af:	5e                   	pop    %esi
801096b0:	5f                   	pop    %edi
801096b1:	5d                   	pop    %ebp
801096b2:	c3                   	ret    

801096b3 <get_max_disk>:

int get_max_disk(int vc_num){
801096b3:	55                   	push   %ebp
801096b4:	89 e5                	mov    %esp,%ebp
801096b6:	57                   	push   %edi
801096b7:	56                   	push   %esi
801096b8:	53                   	push   %ebx
801096b9:	83 ec 50             	sub    $0x50,%esp
	struct container x = containers[vc_num];
801096bc:	8b 45 08             	mov    0x8(%ebp),%eax
801096bf:	c1 e0 02             	shl    $0x2,%eax
801096c2:	89 c2                	mov    %eax,%edx
801096c4:	c1 e2 04             	shl    $0x4,%edx
801096c7:	01 d0                	add    %edx,%eax
801096c9:	05 60 8d 11 80       	add    $0x80118d60,%eax
801096ce:	8d 55 b0             	lea    -0x50(%ebp),%edx
801096d1:	89 c3                	mov    %eax,%ebx
801096d3:	b8 11 00 00 00       	mov    $0x11,%eax
801096d8:	89 d7                	mov    %edx,%edi
801096da:	89 de                	mov    %ebx,%esi
801096dc:	89 c1                	mov    %eax,%ecx
801096de:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_disk;
801096e0:	8b 45 b8             	mov    -0x48(%ebp),%eax
}
801096e3:	83 c4 50             	add    $0x50,%esp
801096e6:	5b                   	pop    %ebx
801096e7:	5e                   	pop    %esi
801096e8:	5f                   	pop    %edi
801096e9:	5d                   	pop    %ebp
801096ea:	c3                   	ret    

801096eb <get_curr_proc>:

int get_curr_proc(int vc_num){
801096eb:	55                   	push   %ebp
801096ec:	89 e5                	mov    %esp,%ebp
801096ee:	57                   	push   %edi
801096ef:	56                   	push   %esi
801096f0:	53                   	push   %ebx
801096f1:	83 ec 50             	sub    $0x50,%esp
	struct container x = containers[vc_num];
801096f4:	8b 45 08             	mov    0x8(%ebp),%eax
801096f7:	c1 e0 02             	shl    $0x2,%eax
801096fa:	89 c2                	mov    %eax,%edx
801096fc:	c1 e2 04             	shl    $0x4,%edx
801096ff:	01 d0                	add    %edx,%eax
80109701:	05 60 8d 11 80       	add    $0x80118d60,%eax
80109706:	8d 55 b0             	lea    -0x50(%ebp),%edx
80109709:	89 c3                	mov    %eax,%ebx
8010970b:	b8 11 00 00 00       	mov    $0x11,%eax
80109710:	89 d7                	mov    %edx,%edi
80109712:	89 de                	mov    %ebx,%esi
80109714:	89 c1                	mov    %eax,%ecx
80109716:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_proc;
80109718:	8b 45 c0             	mov    -0x40(%ebp),%eax
}
8010971b:	83 c4 50             	add    $0x50,%esp
8010971e:	5b                   	pop    %ebx
8010971f:	5e                   	pop    %esi
80109720:	5f                   	pop    %edi
80109721:	5d                   	pop    %ebp
80109722:	c3                   	ret    

80109723 <get_curr_mem>:

int get_curr_mem(int vc_num){
80109723:	55                   	push   %ebp
80109724:	89 e5                	mov    %esp,%ebp
80109726:	57                   	push   %edi
80109727:	56                   	push   %esi
80109728:	53                   	push   %ebx
80109729:	83 ec 50             	sub    $0x50,%esp
	struct container x = containers[vc_num];
8010972c:	8b 45 08             	mov    0x8(%ebp),%eax
8010972f:	c1 e0 02             	shl    $0x2,%eax
80109732:	89 c2                	mov    %eax,%edx
80109734:	c1 e2 04             	shl    $0x4,%edx
80109737:	01 d0                	add    %edx,%eax
80109739:	05 60 8d 11 80       	add    $0x80118d60,%eax
8010973e:	8d 55 b0             	lea    -0x50(%ebp),%edx
80109741:	89 c3                	mov    %eax,%ebx
80109743:	b8 11 00 00 00       	mov    $0x11,%eax
80109748:	89 d7                	mov    %edx,%edi
8010974a:	89 de                	mov    %ebx,%esi
8010974c:	89 c1                	mov    %eax,%ecx
8010974e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	// cprintf("curr mem is called. Val : %d.\n", x.curr_mem);
	return x.curr_mem; 
80109750:	8b 45 bc             	mov    -0x44(%ebp),%eax
}
80109753:	83 c4 50             	add    $0x50,%esp
80109756:	5b                   	pop    %ebx
80109757:	5e                   	pop    %esi
80109758:	5f                   	pop    %edi
80109759:	5d                   	pop    %ebp
8010975a:	c3                   	ret    

8010975b <get_curr_disk>:

int get_curr_disk(int vc_num){
8010975b:	55                   	push   %ebp
8010975c:	89 e5                	mov    %esp,%ebp
8010975e:	57                   	push   %edi
8010975f:	56                   	push   %esi
80109760:	53                   	push   %ebx
80109761:	83 ec 50             	sub    $0x50,%esp
	struct container x = containers[vc_num];
80109764:	8b 45 08             	mov    0x8(%ebp),%eax
80109767:	c1 e0 02             	shl    $0x2,%eax
8010976a:	89 c2                	mov    %eax,%edx
8010976c:	c1 e2 04             	shl    $0x4,%edx
8010976f:	01 d0                	add    %edx,%eax
80109771:	05 60 8d 11 80       	add    $0x80118d60,%eax
80109776:	8d 55 b0             	lea    -0x50(%ebp),%edx
80109779:	89 c3                	mov    %eax,%ebx
8010977b:	b8 11 00 00 00       	mov    $0x11,%eax
80109780:	89 d7                	mov    %edx,%edi
80109782:	89 de                	mov    %ebx,%esi
80109784:	89 c1                	mov    %eax,%ecx
80109786:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_disk;	
80109788:	8b 45 c4             	mov    -0x3c(%ebp),%eax
}
8010978b:	83 c4 50             	add    $0x50,%esp
8010978e:	5b                   	pop    %ebx
8010978f:	5e                   	pop    %esi
80109790:	5f                   	pop    %edi
80109791:	5d                   	pop    %ebp
80109792:	c3                   	ret    

80109793 <set_name>:

void set_name(char* name, int vc_num){
80109793:	55                   	push   %ebp
80109794:	89 e5                	mov    %esp,%ebp
80109796:	83 ec 08             	sub    $0x8,%esp
	strcpy(containers[vc_num].name, name);
80109799:	8b 45 0c             	mov    0xc(%ebp),%eax
8010979c:	c1 e0 02             	shl    $0x2,%eax
8010979f:	89 c2                	mov    %eax,%edx
801097a1:	c1 e2 04             	shl    $0x4,%edx
801097a4:	01 d0                	add    %edx,%eax
801097a6:	83 c0 10             	add    $0x10,%eax
801097a9:	05 60 8d 11 80       	add    $0x80118d60,%eax
801097ae:	8d 50 0c             	lea    0xc(%eax),%edx
801097b1:	8b 45 08             	mov    0x8(%ebp),%eax
801097b4:	89 44 24 04          	mov    %eax,0x4(%esp)
801097b8:	89 14 24             	mov    %edx,(%esp)
801097bb:	e8 35 fc ff ff       	call   801093f5 <strcpy>
}
801097c0:	c9                   	leave  
801097c1:	c3                   	ret    

801097c2 <set_max_mem>:

void set_max_mem(int mem, int vc_num){
801097c2:	55                   	push   %ebp
801097c3:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_mem = mem;
801097c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801097c8:	c1 e0 02             	shl    $0x2,%eax
801097cb:	89 c2                	mov    %eax,%edx
801097cd:	c1 e2 04             	shl    $0x4,%edx
801097d0:	01 d0                	add    %edx,%eax
801097d2:	8d 90 60 8d 11 80    	lea    -0x7fee72a0(%eax),%edx
801097d8:	8b 45 08             	mov    0x8(%ebp),%eax
801097db:	89 02                	mov    %eax,(%edx)
}
801097dd:	5d                   	pop    %ebp
801097de:	c3                   	ret    

801097df <set_os>:

void set_os(int os){
801097df:	55                   	push   %ebp
801097e0:	89 e5                	mov    %esp,%ebp
	disk_used += os;
801097e2:	8b 15 68 d9 10 80    	mov    0x8010d968,%edx
801097e8:	8b 45 08             	mov    0x8(%ebp),%eax
801097eb:	01 d0                	add    %edx,%eax
801097ed:	a3 68 d9 10 80       	mov    %eax,0x8010d968
}
801097f2:	5d                   	pop    %ebp
801097f3:	c3                   	ret    

801097f4 <set_max_disk>:

void set_max_disk(int disk, int vc_num){
801097f4:	55                   	push   %ebp
801097f5:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_disk = disk;
801097f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801097fa:	c1 e0 02             	shl    $0x2,%eax
801097fd:	89 c2                	mov    %eax,%edx
801097ff:	c1 e2 04             	shl    $0x4,%edx
80109802:	01 d0                	add    %edx,%eax
80109804:	8d 90 60 8d 11 80    	lea    -0x7fee72a0(%eax),%edx
8010980a:	8b 45 08             	mov    0x8(%ebp),%eax
8010980d:	89 42 08             	mov    %eax,0x8(%edx)
}
80109810:	5d                   	pop    %ebp
80109811:	c3                   	ret    

80109812 <set_max_proc>:

void set_max_proc(int procs, int vc_num){
80109812:	55                   	push   %ebp
80109813:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_proc = procs;
80109815:	8b 45 0c             	mov    0xc(%ebp),%eax
80109818:	c1 e0 02             	shl    $0x2,%eax
8010981b:	89 c2                	mov    %eax,%edx
8010981d:	c1 e2 04             	shl    $0x4,%edx
80109820:	01 d0                	add    %edx,%eax
80109822:	8d 90 60 8d 11 80    	lea    -0x7fee72a0(%eax),%edx
80109828:	8b 45 08             	mov    0x8(%ebp),%eax
8010982b:	89 42 04             	mov    %eax,0x4(%edx)
}
8010982e:	5d                   	pop    %ebp
8010982f:	c3                   	ret    

80109830 <set_curr_mem>:

void set_curr_mem(int mem, int vc_num){
80109830:	55                   	push   %ebp
80109831:	89 e5                	mov    %esp,%ebp
80109833:	83 ec 18             	sub    $0x18,%esp
	if((containers[vc_num].curr_mem + 1) > containers[vc_num].max_mem){
80109836:	8b 45 0c             	mov    0xc(%ebp),%eax
80109839:	c1 e0 02             	shl    $0x2,%eax
8010983c:	89 c2                	mov    %eax,%edx
8010983e:	c1 e2 04             	shl    $0x4,%edx
80109841:	01 d0                	add    %edx,%eax
80109843:	05 60 8d 11 80       	add    $0x80118d60,%eax
80109848:	8b 40 0c             	mov    0xc(%eax),%eax
8010984b:	8d 50 01             	lea    0x1(%eax),%edx
8010984e:	8b 45 0c             	mov    0xc(%ebp),%eax
80109851:	c1 e0 02             	shl    $0x2,%eax
80109854:	89 c1                	mov    %eax,%ecx
80109856:	c1 e1 04             	shl    $0x4,%ecx
80109859:	01 c8                	add    %ecx,%eax
8010985b:	05 60 8d 11 80       	add    $0x80118d60,%eax
80109860:	8b 00                	mov    (%eax),%eax
80109862:	39 c2                	cmp    %eax,%edx
80109864:	7e 0e                	jle    80109874 <set_curr_mem+0x44>
		cprintf("Exceded memory resource; killing container\n");
80109866:	c7 04 24 e4 a5 10 80 	movl   $0x8010a5e4,(%esp)
8010986d:	e8 4f 6b ff ff       	call   801003c1 <cprintf>
80109872:	eb 2d                	jmp    801098a1 <set_curr_mem+0x71>
	}
	else{
		containers[vc_num].curr_mem = containers[vc_num].curr_mem + 1;
80109874:	8b 45 0c             	mov    0xc(%ebp),%eax
80109877:	c1 e0 02             	shl    $0x2,%eax
8010987a:	89 c2                	mov    %eax,%edx
8010987c:	c1 e2 04             	shl    $0x4,%edx
8010987f:	01 d0                	add    %edx,%eax
80109881:	05 60 8d 11 80       	add    $0x80118d60,%eax
80109886:	8b 40 0c             	mov    0xc(%eax),%eax
80109889:	8d 50 01             	lea    0x1(%eax),%edx
8010988c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010988f:	c1 e0 02             	shl    $0x2,%eax
80109892:	89 c1                	mov    %eax,%ecx
80109894:	c1 e1 04             	shl    $0x4,%ecx
80109897:	01 c8                	add    %ecx,%eax
80109899:	05 60 8d 11 80       	add    $0x80118d60,%eax
8010989e:	89 50 0c             	mov    %edx,0xc(%eax)
	}
}
801098a1:	c9                   	leave  
801098a2:	c3                   	ret    

801098a3 <reduce_curr_mem>:

void reduce_curr_mem(int mem, int vc_num){
801098a3:	55                   	push   %ebp
801098a4:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_mem = containers[vc_num].curr_mem - 1;	
801098a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801098a9:	c1 e0 02             	shl    $0x2,%eax
801098ac:	89 c2                	mov    %eax,%edx
801098ae:	c1 e2 04             	shl    $0x4,%edx
801098b1:	01 d0                	add    %edx,%eax
801098b3:	05 60 8d 11 80       	add    $0x80118d60,%eax
801098b8:	8b 40 0c             	mov    0xc(%eax),%eax
801098bb:	8d 50 ff             	lea    -0x1(%eax),%edx
801098be:	8b 45 0c             	mov    0xc(%ebp),%eax
801098c1:	c1 e0 02             	shl    $0x2,%eax
801098c4:	89 c1                	mov    %eax,%ecx
801098c6:	c1 e1 04             	shl    $0x4,%ecx
801098c9:	01 c8                	add    %ecx,%eax
801098cb:	05 60 8d 11 80       	add    $0x80118d60,%eax
801098d0:	89 50 0c             	mov    %edx,0xc(%eax)
}
801098d3:	5d                   	pop    %ebp
801098d4:	c3                   	ret    

801098d5 <set_curr_disk>:

void set_curr_disk(int disk, int vc_num){
801098d5:	55                   	push   %ebp
801098d6:	89 e5                	mov    %esp,%ebp
801098d8:	83 ec 18             	sub    $0x18,%esp
	if((containers[vc_num].curr_disk + disk)/1024 > containers[vc_num].max_disk){
801098db:	8b 45 0c             	mov    0xc(%ebp),%eax
801098de:	c1 e0 02             	shl    $0x2,%eax
801098e1:	89 c2                	mov    %eax,%edx
801098e3:	c1 e2 04             	shl    $0x4,%edx
801098e6:	01 d0                	add    %edx,%eax
801098e8:	05 70 8d 11 80       	add    $0x80118d70,%eax
801098ed:	8b 50 04             	mov    0x4(%eax),%edx
801098f0:	8b 45 08             	mov    0x8(%ebp),%eax
801098f3:	01 d0                	add    %edx,%eax
801098f5:	85 c0                	test   %eax,%eax
801098f7:	79 05                	jns    801098fe <set_curr_disk+0x29>
801098f9:	05 ff 03 00 00       	add    $0x3ff,%eax
801098fe:	c1 f8 0a             	sar    $0xa,%eax
80109901:	89 c2                	mov    %eax,%edx
80109903:	8b 45 0c             	mov    0xc(%ebp),%eax
80109906:	c1 e0 02             	shl    $0x2,%eax
80109909:	89 c1                	mov    %eax,%ecx
8010990b:	c1 e1 04             	shl    $0x4,%ecx
8010990e:	01 c8                	add    %ecx,%eax
80109910:	05 60 8d 11 80       	add    $0x80118d60,%eax
80109915:	8b 40 08             	mov    0x8(%eax),%eax
80109918:	39 c2                	cmp    %eax,%edx
8010991a:	7e 0e                	jle    8010992a <set_curr_disk+0x55>
		cprintf("Exceded disk resource; killing container\n");
8010991c:	c7 04 24 10 a6 10 80 	movl   $0x8010a610,(%esp)
80109923:	e8 99 6a ff ff       	call   801003c1 <cprintf>
80109928:	eb 2f                	jmp    80109959 <set_curr_disk+0x84>
	}
	else{
		containers[vc_num].curr_disk += disk;
8010992a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010992d:	c1 e0 02             	shl    $0x2,%eax
80109930:	89 c2                	mov    %eax,%edx
80109932:	c1 e2 04             	shl    $0x4,%edx
80109935:	01 d0                	add    %edx,%eax
80109937:	05 70 8d 11 80       	add    $0x80118d70,%eax
8010993c:	8b 50 04             	mov    0x4(%eax),%edx
8010993f:	8b 45 08             	mov    0x8(%ebp),%eax
80109942:	01 c2                	add    %eax,%edx
80109944:	8b 45 0c             	mov    0xc(%ebp),%eax
80109947:	c1 e0 02             	shl    $0x2,%eax
8010994a:	89 c1                	mov    %eax,%ecx
8010994c:	c1 e1 04             	shl    $0x4,%ecx
8010994f:	01 c8                	add    %ecx,%eax
80109951:	05 70 8d 11 80       	add    $0x80118d70,%eax
80109956:	89 50 04             	mov    %edx,0x4(%eax)
	}
}
80109959:	c9                   	leave  
8010995a:	c3                   	ret    

8010995b <set_curr_proc>:

void set_curr_proc(int procs, int vc_num){
8010995b:	55                   	push   %ebp
8010995c:	89 e5                	mov    %esp,%ebp
8010995e:	83 ec 18             	sub    $0x18,%esp
	if(containers[vc_num].curr_proc + procs > containers[vc_num].max_proc){
80109961:	8b 45 0c             	mov    0xc(%ebp),%eax
80109964:	c1 e0 02             	shl    $0x2,%eax
80109967:	89 c2                	mov    %eax,%edx
80109969:	c1 e2 04             	shl    $0x4,%edx
8010996c:	01 d0                	add    %edx,%eax
8010996e:	05 70 8d 11 80       	add    $0x80118d70,%eax
80109973:	8b 10                	mov    (%eax),%edx
80109975:	8b 45 08             	mov    0x8(%ebp),%eax
80109978:	01 c2                	add    %eax,%edx
8010997a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010997d:	c1 e0 02             	shl    $0x2,%eax
80109980:	89 c1                	mov    %eax,%ecx
80109982:	c1 e1 04             	shl    $0x4,%ecx
80109985:	01 c8                	add    %ecx,%eax
80109987:	05 60 8d 11 80       	add    $0x80118d60,%eax
8010998c:	8b 40 04             	mov    0x4(%eax),%eax
8010998f:	39 c2                	cmp    %eax,%edx
80109991:	7e 0e                	jle    801099a1 <set_curr_proc+0x46>
		cprintf("Exceded procs resource; killing container\n");
80109993:	c7 04 24 3c a6 10 80 	movl   $0x8010a63c,(%esp)
8010999a:	e8 22 6a ff ff       	call   801003c1 <cprintf>
8010999f:	eb 2d                	jmp    801099ce <set_curr_proc+0x73>
	}
	else{
		containers[vc_num].curr_proc += procs;
801099a1:	8b 45 0c             	mov    0xc(%ebp),%eax
801099a4:	c1 e0 02             	shl    $0x2,%eax
801099a7:	89 c2                	mov    %eax,%edx
801099a9:	c1 e2 04             	shl    $0x4,%edx
801099ac:	01 d0                	add    %edx,%eax
801099ae:	05 70 8d 11 80       	add    $0x80118d70,%eax
801099b3:	8b 10                	mov    (%eax),%edx
801099b5:	8b 45 08             	mov    0x8(%ebp),%eax
801099b8:	01 c2                	add    %eax,%edx
801099ba:	8b 45 0c             	mov    0xc(%ebp),%eax
801099bd:	c1 e0 02             	shl    $0x2,%eax
801099c0:	89 c1                	mov    %eax,%ecx
801099c2:	c1 e1 04             	shl    $0x4,%ecx
801099c5:	01 c8                	add    %ecx,%eax
801099c7:	05 70 8d 11 80       	add    $0x80118d70,%eax
801099cc:	89 10                	mov    %edx,(%eax)
	}
}
801099ce:	c9                   	leave  
801099cf:	c3                   	ret    

801099d0 <max_containers>:

int max_containers(){
801099d0:	55                   	push   %ebp
801099d1:	89 e5                	mov    %esp,%ebp
	return MAX_CONTAINERS;
801099d3:	b8 04 00 00 00       	mov    $0x4,%eax
}
801099d8:	5d                   	pop    %ebp
801099d9:	c3                   	ret    

801099da <rand>:

int rand(void) // RAND_MAX assumed to be 32767
{
801099da:	55                   	push   %ebp
801099db:	89 e5                	mov    %esp,%ebp
    next = next * 1103515245 + 12345;
801099dd:	8b 0d a0 d5 10 80    	mov    0x8010d5a0,%ecx
801099e3:	89 ca                	mov    %ecx,%edx
801099e5:	89 d0                	mov    %edx,%eax
801099e7:	c1 e0 09             	shl    $0x9,%eax
801099ea:	89 c2                	mov    %eax,%edx
801099ec:	29 ca                	sub    %ecx,%edx
801099ee:	c1 e2 02             	shl    $0x2,%edx
801099f1:	01 ca                	add    %ecx,%edx
801099f3:	89 d0                	mov    %edx,%eax
801099f5:	c1 e0 09             	shl    $0x9,%eax
801099f8:	29 d0                	sub    %edx,%eax
801099fa:	01 c0                	add    %eax,%eax
801099fc:	01 c8                	add    %ecx,%eax
801099fe:	89 c2                	mov    %eax,%edx
80109a00:	c1 e2 05             	shl    $0x5,%edx
80109a03:	01 d0                	add    %edx,%eax
80109a05:	c1 e0 02             	shl    $0x2,%eax
80109a08:	29 c8                	sub    %ecx,%eax
80109a0a:	c1 e0 02             	shl    $0x2,%eax
80109a0d:	01 c8                	add    %ecx,%eax
80109a0f:	05 39 30 00 00       	add    $0x3039,%eax
80109a14:	a3 a0 d5 10 80       	mov    %eax,0x8010d5a0
    return (unsigned int)(next/65536) % 7;
80109a19:	a1 a0 d5 10 80       	mov    0x8010d5a0,%eax
80109a1e:	85 c0                	test   %eax,%eax
80109a20:	79 05                	jns    80109a27 <rand+0x4d>
80109a22:	05 ff ff 00 00       	add    $0xffff,%eax
80109a27:	c1 f8 10             	sar    $0x10,%eax
80109a2a:	b9 07 00 00 00       	mov    $0x7,%ecx
80109a2f:	ba 00 00 00 00       	mov    $0x0,%edx
80109a34:	f7 f1                	div    %ecx
80109a36:	89 d0                	mov    %edx,%eax
}
80109a38:	5d                   	pop    %ebp
80109a39:	c3                   	ret    

80109a3a <get_cticks>:

int get_cticks(){
80109a3a:	55                   	push   %ebp
80109a3b:	89 e5                	mov    %esp,%ebp
80109a3d:	83 ec 18             	sub    $0x18,%esp
	if(get_used() == 0){
80109a40:	e8 b2 fa ff ff       	call   801094f7 <get_used>
80109a45:	85 c0                	test   %eax,%eax
80109a47:	75 07                	jne    80109a50 <get_cticks+0x16>
		return -1;
80109a49:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109a4e:	eb 7f                	jmp    80109acf <get_cticks+0x95>
	}
	else if(rand() == 0){
80109a50:	e8 85 ff ff ff       	call   801099da <rand>
80109a55:	85 c0                	test   %eax,%eax
80109a57:	75 07                	jne    80109a60 <get_cticks+0x26>
		return -1;
80109a59:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109a5e:	eb 6f                	jmp    80109acf <get_cticks+0x95>
	}
	else{
		int i;
		int c_num = 0;
80109a60:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
		int holder = containers[0].ticks;
80109a67:	a1 a0 8d 11 80       	mov    0x80118da0,%eax
80109a6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
		for(i = 0; i < MAX_CONTAINERS; i++){
80109a6f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80109a76:	eb 4e                	jmp    80109ac6 <get_cticks+0x8c>
			if(containers[i].ticks < holder && strcmp(containers[i].name, "") != 0){
80109a78:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109a7b:	c1 e0 02             	shl    $0x2,%eax
80109a7e:	89 c2                	mov    %eax,%edx
80109a80:	c1 e2 04             	shl    $0x4,%edx
80109a83:	01 d0                	add    %edx,%eax
80109a85:	05 a0 8d 11 80       	add    $0x80118da0,%eax
80109a8a:	8b 00                	mov    (%eax),%eax
80109a8c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80109a8f:	7d 32                	jge    80109ac3 <get_cticks+0x89>
80109a91:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109a94:	c1 e0 02             	shl    $0x2,%eax
80109a97:	89 c2                	mov    %eax,%edx
80109a99:	c1 e2 04             	shl    $0x4,%edx
80109a9c:	01 d0                	add    %edx,%eax
80109a9e:	83 c0 10             	add    $0x10,%eax
80109aa1:	05 60 8d 11 80       	add    $0x80118d60,%eax
80109aa6:	83 c0 0c             	add    $0xc,%eax
80109aa9:	c7 44 24 04 e0 a5 10 	movl   $0x8010a5e0,0x4(%esp)
80109ab0:	80 
80109ab1:	89 04 24             	mov    %eax,(%esp)
80109ab4:	e8 6a f9 ff ff       	call   80109423 <strcmp>
80109ab9:	85 c0                	test   %eax,%eax
80109abb:	74 06                	je     80109ac3 <get_cticks+0x89>
				c_num = i;
80109abd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109ac0:	89 45 f8             	mov    %eax,-0x8(%ebp)
	}
	else{
		int i;
		int c_num = 0;
		int holder = containers[0].ticks;
		for(i = 0; i < MAX_CONTAINERS; i++){
80109ac3:	ff 45 fc             	incl   -0x4(%ebp)
80109ac6:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
80109aca:	7e ac                	jle    80109a78 <get_cticks+0x3e>
			if(containers[i].ticks < holder && strcmp(containers[i].name, "") != 0){
				c_num = i;
			}
		}
		return c_num;
80109acc:	8b 45 f8             	mov    -0x8(%ebp),%eax
	}
}
80109acf:	c9                   	leave  
80109ad0:	c3                   	ret    

80109ad1 <container_init>:

void container_init(){
80109ad1:	55                   	push   %ebp
80109ad2:	89 e5                	mov    %esp,%ebp
80109ad4:	83 ec 18             	sub    $0x18,%esp
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80109ad7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80109ade:	e9 d7 00 00 00       	jmp    80109bba <container_init+0xe9>
		strcpy(containers[i].name, "");
80109ae3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109ae6:	c1 e0 02             	shl    $0x2,%eax
80109ae9:	89 c2                	mov    %eax,%edx
80109aeb:	c1 e2 04             	shl    $0x4,%edx
80109aee:	01 d0                	add    %edx,%eax
80109af0:	83 c0 10             	add    $0x10,%eax
80109af3:	05 60 8d 11 80       	add    $0x80118d60,%eax
80109af8:	83 c0 0c             	add    $0xc,%eax
80109afb:	c7 44 24 04 e0 a5 10 	movl   $0x8010a5e0,0x4(%esp)
80109b02:	80 
80109b03:	89 04 24             	mov    %eax,(%esp)
80109b06:	e8 ea f8 ff ff       	call   801093f5 <strcpy>
		containers[i].max_proc = 6;
80109b0b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109b0e:	c1 e0 02             	shl    $0x2,%eax
80109b11:	89 c2                	mov    %eax,%edx
80109b13:	c1 e2 04             	shl    $0x4,%edx
80109b16:	01 d0                	add    %edx,%eax
80109b18:	05 60 8d 11 80       	add    $0x80118d60,%eax
80109b1d:	c7 40 04 06 00 00 00 	movl   $0x6,0x4(%eax)
		containers[i].max_disk = 100;
80109b24:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109b27:	c1 e0 02             	shl    $0x2,%eax
80109b2a:	89 c2                	mov    %eax,%edx
80109b2c:	c1 e2 04             	shl    $0x4,%edx
80109b2f:	01 d0                	add    %edx,%eax
80109b31:	05 60 8d 11 80       	add    $0x80118d60,%eax
80109b36:	c7 40 08 64 00 00 00 	movl   $0x64,0x8(%eax)
		containers[i].max_mem = 500;
80109b3d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109b40:	c1 e0 02             	shl    $0x2,%eax
80109b43:	89 c2                	mov    %eax,%edx
80109b45:	c1 e2 04             	shl    $0x4,%edx
80109b48:	01 d0                	add    %edx,%eax
80109b4a:	05 60 8d 11 80       	add    $0x80118d60,%eax
80109b4f:	c7 00 f4 01 00 00    	movl   $0x1f4,(%eax)
		containers[i].curr_proc = 1;
80109b55:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109b58:	c1 e0 02             	shl    $0x2,%eax
80109b5b:	89 c2                	mov    %eax,%edx
80109b5d:	c1 e2 04             	shl    $0x4,%edx
80109b60:	01 d0                	add    %edx,%eax
80109b62:	05 70 8d 11 80       	add    $0x80118d70,%eax
80109b67:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
		containers[i].curr_disk = 0;
80109b6d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109b70:	c1 e0 02             	shl    $0x2,%eax
80109b73:	89 c2                	mov    %eax,%edx
80109b75:	c1 e2 04             	shl    $0x4,%edx
80109b78:	01 d0                	add    %edx,%eax
80109b7a:	05 70 8d 11 80       	add    $0x80118d70,%eax
80109b7f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		containers[i].curr_mem = 0;
80109b86:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109b89:	c1 e0 02             	shl    $0x2,%eax
80109b8c:	89 c2                	mov    %eax,%edx
80109b8e:	c1 e2 04             	shl    $0x4,%edx
80109b91:	01 d0                	add    %edx,%eax
80109b93:	05 60 8d 11 80       	add    $0x80118d60,%eax
80109b98:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
		containers[i].ticks = 0;
80109b9f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109ba2:	c1 e0 02             	shl    $0x2,%eax
80109ba5:	89 c2                	mov    %eax,%edx
80109ba7:	c1 e2 04             	shl    $0x4,%edx
80109baa:	01 d0                	add    %edx,%eax
80109bac:	05 a0 8d 11 80       	add    $0x80118da0,%eax
80109bb1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
}

void container_init(){
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80109bb7:	ff 45 fc             	incl   -0x4(%ebp)
80109bba:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
80109bbe:	0f 8e 1f ff ff ff    	jle    80109ae3 <container_init+0x12>
		containers[i].curr_proc = 1;
		containers[i].curr_disk = 0;
		containers[i].curr_mem = 0;
		containers[i].ticks = 0;
	}
}
80109bc4:	c9                   	leave  
80109bc5:	c3                   	ret    

80109bc6 <tick_reset2>:

void tick_reset2(){
80109bc6:	55                   	push   %ebp
80109bc7:	89 e5                	mov    %esp,%ebp
80109bc9:	83 ec 10             	sub    $0x10,%esp
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80109bcc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80109bd3:	eb 1b                	jmp    80109bf0 <tick_reset2+0x2a>
		containers[i].ticks = 0;
80109bd5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109bd8:	c1 e0 02             	shl    $0x2,%eax
80109bdb:	89 c2                	mov    %eax,%edx
80109bdd:	c1 e2 04             	shl    $0x4,%edx
80109be0:	01 d0                	add    %edx,%eax
80109be2:	05 a0 8d 11 80       	add    $0x80118da0,%eax
80109be7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
}

void tick_reset2(){
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80109bed:	ff 45 fc             	incl   -0x4(%ebp)
80109bf0:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
80109bf4:	7e df                	jle    80109bd5 <tick_reset2+0xf>
		containers[i].ticks = 0;
	}
}
80109bf6:	c9                   	leave  
80109bf7:	c3                   	ret    

80109bf8 <container_reset>:


void container_reset(int vc_num){
80109bf8:	55                   	push   %ebp
80109bf9:	89 e5                	mov    %esp,%ebp
80109bfb:	83 ec 08             	sub    $0x8,%esp
	strcpy(containers[vc_num].name, "");
80109bfe:	8b 45 08             	mov    0x8(%ebp),%eax
80109c01:	c1 e0 02             	shl    $0x2,%eax
80109c04:	89 c2                	mov    %eax,%edx
80109c06:	c1 e2 04             	shl    $0x4,%edx
80109c09:	01 d0                	add    %edx,%eax
80109c0b:	83 c0 10             	add    $0x10,%eax
80109c0e:	05 60 8d 11 80       	add    $0x80118d60,%eax
80109c13:	83 c0 0c             	add    $0xc,%eax
80109c16:	c7 44 24 04 e0 a5 10 	movl   $0x8010a5e0,0x4(%esp)
80109c1d:	80 
80109c1e:	89 04 24             	mov    %eax,(%esp)
80109c21:	e8 cf f7 ff ff       	call   801093f5 <strcpy>
	containers[vc_num].max_proc = 6;
80109c26:	8b 45 08             	mov    0x8(%ebp),%eax
80109c29:	c1 e0 02             	shl    $0x2,%eax
80109c2c:	89 c2                	mov    %eax,%edx
80109c2e:	c1 e2 04             	shl    $0x4,%edx
80109c31:	01 d0                	add    %edx,%eax
80109c33:	05 60 8d 11 80       	add    $0x80118d60,%eax
80109c38:	c7 40 04 06 00 00 00 	movl   $0x6,0x4(%eax)
	containers[vc_num].max_disk = 100;
80109c3f:	8b 45 08             	mov    0x8(%ebp),%eax
80109c42:	c1 e0 02             	shl    $0x2,%eax
80109c45:	89 c2                	mov    %eax,%edx
80109c47:	c1 e2 04             	shl    $0x4,%edx
80109c4a:	01 d0                	add    %edx,%eax
80109c4c:	05 60 8d 11 80       	add    $0x80118d60,%eax
80109c51:	c7 40 08 64 00 00 00 	movl   $0x64,0x8(%eax)
	containers[vc_num].max_mem = 500;
80109c58:	8b 45 08             	mov    0x8(%ebp),%eax
80109c5b:	c1 e0 02             	shl    $0x2,%eax
80109c5e:	89 c2                	mov    %eax,%edx
80109c60:	c1 e2 04             	shl    $0x4,%edx
80109c63:	01 d0                	add    %edx,%eax
80109c65:	05 60 8d 11 80       	add    $0x80118d60,%eax
80109c6a:	c7 00 f4 01 00 00    	movl   $0x1f4,(%eax)
	containers[vc_num].curr_proc = 1;
80109c70:	8b 45 08             	mov    0x8(%ebp),%eax
80109c73:	c1 e0 02             	shl    $0x2,%eax
80109c76:	89 c2                	mov    %eax,%edx
80109c78:	c1 e2 04             	shl    $0x4,%edx
80109c7b:	01 d0                	add    %edx,%eax
80109c7d:	05 70 8d 11 80       	add    $0x80118d70,%eax
80109c82:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
	containers[vc_num].curr_disk = 0;
80109c88:	8b 45 08             	mov    0x8(%ebp),%eax
80109c8b:	c1 e0 02             	shl    $0x2,%eax
80109c8e:	89 c2                	mov    %eax,%edx
80109c90:	c1 e2 04             	shl    $0x4,%edx
80109c93:	01 d0                	add    %edx,%eax
80109c95:	05 70 8d 11 80       	add    $0x80118d70,%eax
80109c9a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	containers[vc_num].curr_mem = 0;
80109ca1:	8b 45 08             	mov    0x8(%ebp),%eax
80109ca4:	c1 e0 02             	shl    $0x2,%eax
80109ca7:	89 c2                	mov    %eax,%edx
80109ca9:	c1 e2 04             	shl    $0x4,%edx
80109cac:	01 d0                	add    %edx,%eax
80109cae:	05 60 8d 11 80       	add    $0x80118d60,%eax
80109cb3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
	containers[vc_num].ticks = 0;
80109cba:	8b 45 08             	mov    0x8(%ebp),%eax
80109cbd:	c1 e0 02             	shl    $0x2,%eax
80109cc0:	89 c2                	mov    %eax,%edx
80109cc2:	c1 e2 04             	shl    $0x4,%edx
80109cc5:	01 d0                	add    %edx,%eax
80109cc7:	05 a0 8d 11 80       	add    $0x80118da0,%eax
80109ccc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80109cd2:	c9                   	leave  
80109cd3:	c3                   	ret    
